param(
    [string]$Agent,
    [string]$Prompt,
    [string]$Model = "gpt-4o-mini",
    [string]$Endpoint = "",
    [switch]$Raw,
    [switch]$AllowEdits,
    [switch]$Live,
    [int]$MaxHistoryItems = 20,
    [int]$MaxTextChars = 2000,
    [int]$MaxApiRetries = 6,
    [int]$RetryDelaySeconds = 12,
    [string]$SessionName = "",
    [string]$SessionDir = "",
    [string]$SequencePath = "",
    [int]$MaxSteps = 20
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($SessionDir)) {
    $SessionDir = Join-Path $repoRoot ".agent-sessions"
}

if ([string]::IsNullOrWhiteSpace($SequencePath)) {
    if ([string]::IsNullOrWhiteSpace($Agent)) {
        throw "Provide -Agent for direct mode or -SequencePath for sequence mode."
    }
    if ([string]::IsNullOrWhiteSpace($Prompt)) {
        throw "Provide -Prompt for direct mode or -SequencePath for sequence mode."
    }
}
elseif (-not [string]::IsNullOrWhiteSpace($Prompt)) {
    throw "Use either -Prompt or -SequencePath, not both."
}

function Ensure-Directory([string]$PathValue) {
    if (-not (Test-Path $PathValue)) {
        New-Item -ItemType Directory -Path $PathValue -Force | Out-Null
    }
}

function Write-Live([string]$Message) {
    if ($Live) {
        $ts = (Get-Date).ToString("HH:mm:ss")
        Write-Host "[$ts] $Message"
    }
}

function Truncate-Text([string]$Text, [int]$MaxChars) {
    if ([string]::IsNullOrEmpty($Text)) { return $Text }
    if ($Text.Length -le $MaxChars) { return $Text }
    return ($Text.Substring(0, $MaxChars) + "`n...[truncated]...")
}

function Get-RetryWaitSeconds([string]$ErrorText, [int]$FallbackSeconds) {
    if ([string]::IsNullOrWhiteSpace($ErrorText)) { return $FallbackSeconds }
    $match = [regex]::Match($ErrorText, '(?i)wait\s+(\d+)\s+seconds')
    if ($match.Success) {
        return [int]$match.Groups[1].Value
    }
    return $FallbackSeconds
}

function Is-RetryableError([string]$ErrorText) {
    if ([string]::IsNullOrWhiteSpace($ErrorText)) { return $false }
    $patterns = @(
        'RateLimitReached',
        'tokens_limit_reached',
        '429',
        '503',
        'temporarily unavailable',
        'please wait'
    )
    foreach ($p in $patterns) {
        if ($ErrorText -match $p) { return $true }
    }
    return $false
}

function Strip-FrontMatter([string]$Text) {
    if ($Text.StartsWith("---")) {
        $match = [regex]::Match($Text, "(?s)^---\r?\n.*?\r?\n---\r?\n")
        if ($match.Success) {
            return $Text.Substring($match.Length)
        }
    }
    return $Text
}

function Get-AvailableAgents {
    $agentDir = Join-Path $repoRoot ".github/agents"
    if (-not (Test-Path $agentDir)) {
        return @()
    }

    $flat = @(Get-ChildItem $agentDir -Filter "*.agent.md" | ForEach-Object { $_.BaseName -replace "\.agent$", "" })
    $nested = @(Get-ChildItem $agentDir -Directory | Where-Object {
            (Test-Path (Join-Path $_.FullName "AGENT.md")) -or (Test-Path (Join-Path $_.FullName "PROMPT.md"))
        } | ForEach-Object { $_.Name })

    return @($flat + $nested | Sort-Object -Unique)
}

function Get-AgentProfile([string]$AgentName) {
    $flatPath = Join-Path $repoRoot ".github/agents/$AgentName.agent.md"
    if (Test-Path $flatPath) {
        return Strip-FrontMatter (Get-Content -Raw -Path $flatPath)
    }

    $dirPath = Join-Path $repoRoot ".github/agents/$AgentName"
    $parts = @()
    $agentPath = Join-Path $dirPath "AGENT.md"
    $promptPath = Join-Path $dirPath "PROMPT.md"

    if (Test-Path $agentPath) {
        $parts += (Get-Content -Raw -Path $agentPath)
    }
    if (Test-Path $promptPath) {
        $parts += (Get-Content -Raw -Path $promptPath)
    }
    if ($parts.Count -gt 0) {
        return ($parts -join "`n`n")
    }

    $available = (Get-AvailableAgents) -join ", "
    throw "Agent profile not found for '$AgentName'. Available agents: $available"
}

function Resolve-SessionPath([string]$Name) {
    Ensure-Directory $SessionDir
    if ([string]::IsNullOrWhiteSpace($Name)) {
        $Name = "session-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    }
    return Join-Path $SessionDir "$Name.json"
}

function New-Session([string]$Name) {
    return [ordered]@{
        sessionName = $Name
        repoRoot    = $repoRoot
        createdAt   = (Get-Date).ToString("o")
        updatedAt   = (Get-Date).ToString("o")
        history     = @()
        results     = @()
    }
}

function Load-Session([string]$PathValue, [string]$FallbackName) {
    if (Test-Path $PathValue) {
        $loaded = Get-Content -Raw -Path $PathValue | ConvertFrom-Json -AsHashtable
        if (-not $loaded.history) { $loaded.history = @() }
        if (-not $loaded.results) { $loaded.results = @() }
        return $loaded
    }
    return (New-Session $FallbackName)
}

function Save-Session([hashtable]$Session, [string]$PathValue) {
    $Session.updatedAt = (Get-Date).ToString("o")
    $Session | ConvertTo-Json -Depth 25 | Set-Content -Path $PathValue -Encoding utf8
}

function Get-Token {
    if ($env:GITHUB_TOKEN) { return $env:GITHUB_TOKEN }
    if ($env:GH_TOKEN) { return $env:GH_TOKEN }
    throw "Missing token. Set GITHUB_TOKEN (or GH_TOKEN) with GitHub Models access."
}

function Resolve-Endpoint([string]$InputEndpoint) {
    if (-not [string]::IsNullOrWhiteSpace($InputEndpoint)) { return $InputEndpoint }
    if ($env:GITHUB_MODELS_ENDPOINT) { return $env:GITHUB_MODELS_ENDPOINT }
    return "https://models.inference.ai.azure.com/chat/completions"
}

function Convert-MessageContentToText($Content) {
    if ($Content -is [System.Array]) {
        return ($Content | ForEach-Object {
                if ($_.text) { $_.text } else { $_ | ConvertTo-Json -Depth 10 }
            }) -join "`n"
    }
    return [string]$Content
}

function Get-EditContractText {
    return @"
When code or file changes are needed, respond with JSON only. No prose outside JSON.

JSON schema:
{
  "status": "success|pass|fail|error|repair-required|defer",
  "summary": "short summary",
  "output": "human-readable explanation",
  "actions": [
    {
      "type": "write_file",
      "path": "relative/path/from/repo/root",
      "content": "full file content"
    },
    {
      "type": "append_file",
      "path": "relative/path/from/repo/root",
      "content": "text to append"
    },
    {
      "type": "replace_text",
      "path": "relative/path/from/repo/root",
      "oldText": "exact old text",
      "newText": "replacement text",
      "replaceAll": false
    },
    {
      "type": "delete_file",
      "path": "relative/path/from/repo/root"
    }
  ]
}

Rules:
- Only use repository-relative paths.
- Do not reference files outside the repo.
- Use write_file when replacing an entire file.
- Use replace_text only when oldText is exact and unique unless replaceAll is true.
- If no edits are needed, return an empty actions array.
"@
}

function Invoke-AgentCall([string]$AgentName, [string]$UserPrompt, [hashtable]$Session, [bool]$Writable, [string]$ContextLabel = "") {
    $agentBody = Get-AgentProfile $AgentName
    $systemText = @"
You are running the local repository agent profile '$AgentName'.
Follow this profile as your governing instructions.
Repository root: $repoRoot

$agentBody
"@
    if ($Writable) {
        $systemText += "`n`n$(Get-EditContractText)"
    }

    $messages = @(@{ role = "system"; content = $systemText })
    $historyItems = @($Session.history)
    if ($MaxHistoryItems -gt 0 -and $historyItems.Count -gt $MaxHistoryItems) {
        $historyItems = @($historyItems | Select-Object -Last $MaxHistoryItems)
    }
    foreach ($entry in $historyItems) {
        $messages += @{ role = $entry.role; content = $entry.content }
    }
    $messages += @{ role = "user"; content = $UserPrompt }

    $payload = @{
        model       = $Model
        messages    = $messages
        temperature = 0.4
    } | ConvertTo-Json -Depth 25

    $headers = @{
        Authorization = "Bearer $(Get-Token)"
        "Content-Type" = "application/json"
    }

    $label = if ([string]::IsNullOrWhiteSpace($ContextLabel)) { $AgentName } else { "${ContextLabel}:${AgentName}" }
    Write-Live "START $label"
    $started = Get-Date
    $response = $null
    for ($attempt = 0; $attempt -le $MaxApiRetries; $attempt++) {
        try {
            $response = Invoke-RestMethod -Method Post -Uri (Resolve-Endpoint $Endpoint) -Headers $headers -Body $payload
            break
        }
        catch {
            $errorText = $_.Exception.Message
            if ($_.ErrorDetails -and $_.ErrorDetails.Message) {
                $errorText += "`n$($_.ErrorDetails.Message)"
            }

            $isRetryable = Is-RetryableError -ErrorText $errorText
            if ((-not $isRetryable) -or $attempt -ge $MaxApiRetries) {
                throw
            }

            $waitSeconds = Get-RetryWaitSeconds -ErrorText $errorText -FallbackSeconds $RetryDelaySeconds
            if ($waitSeconds -lt 1) { $waitSeconds = $RetryDelaySeconds }
            Write-Live "RETRY $label attempt $($attempt + 1)/$MaxApiRetries after ${waitSeconds}s"
            Start-Sleep -Seconds $waitSeconds
        }
    }

    $elapsed = [int]((Get-Date) - $started).TotalSeconds
    Write-Live "DONE  $label in ${elapsed}s"
    if ($null -eq $response.choices -or $response.choices.Count -eq 0) {
        throw "No choices returned from endpoint."
    }

    return Convert-MessageContentToText $response.choices[0].message.content
}

function Strip-CodeFences([string]$Text) {
    $value = $Text.Trim()
    if ($value.StartsWith('```')) {
        $value = [regex]::Replace($value, '^```[a-zA-Z0-9_-]*\s*', '')
        $value = [regex]::Replace($value, '\s*```$', '')
    }
    return $value.Trim()
}

function Try-ParseJson([string]$Text) {
    $candidate = Strip-CodeFences $Text
    try {
        return ($candidate | ConvertFrom-Json -AsHashtable)
    }
    catch {
        return $null
    }
}

function Resolve-RepoPath([string]$RelativePath) {
    $root = [System.IO.Path]::GetFullPath($repoRoot)
    $candidate = [System.IO.Path]::GetFullPath((Join-Path $repoRoot $RelativePath))
    $rootWithSlash = $root.TrimEnd([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar) + [System.IO.Path]::DirectorySeparatorChar
    $repoUri = [System.Uri]$rootWithSlash
    $candidateUri = [System.Uri]$candidate
    if (-not ($repoUri.IsBaseOf($candidateUri))) {
        throw "Refusing to modify path outside repo: $RelativePath"
    }
    return $candidate
}

function Write-Utf8NoBom([string]$PathValue, [string]$Content, [bool]$AppendMode) {
    $dir = Split-Path -Parent $PathValue
    Ensure-Directory $dir
    $encoding = New-Object System.Text.UTF8Encoding($false)
    if ($AppendMode -and (Test-Path $PathValue)) {
        $existing = Get-Content -Raw -Path $PathValue
        [System.IO.File]::WriteAllText($PathValue, ($existing + $Content), $encoding)
    }
    else {
        [System.IO.File]::WriteAllText($PathValue, $Content, $encoding)
    }
}

function Apply-Actions($Actions) {
    $applied = @()
    foreach ($action in @($Actions)) {
        $type = [string]$action.type
        $targetPath = if ($action.path) { Resolve-RepoPath ([string]$action.path) } else { $null }

        switch ($type) {
            "write_file" {
                Write-Utf8NoBom -PathValue $targetPath -Content ([string]$action.content) -AppendMode:$false
                $applied += "write_file:$($action.path)"
            }
            "append_file" {
                Write-Utf8NoBom -PathValue $targetPath -Content ([string]$action.content) -AppendMode:$true
                $applied += "append_file:$($action.path)"
            }
            "replace_text" {
                if (-not (Test-Path $targetPath)) {
                    throw "replace_text target missing: $($action.path)"
                }
                $content = Get-Content -Raw -Path $targetPath
                $oldText = [string]$action.oldText
                $newText = [string]$action.newText
                $replaceAll = $false
                if ($null -ne $action.replaceAll) {
                    $replaceAll = [bool]$action.replaceAll
                }
                $matchCount = ([regex]::Matches($content, [regex]::Escape($oldText))).Count
                if ($matchCount -eq 0) {
                    throw "replace_text oldText not found in $($action.path)"
                }
                if ((-not $replaceAll) -and ($matchCount -gt 1)) {
                    throw "replace_text oldText matched multiple times in $($action.path)"
                }
                if ($replaceAll) {
                    $updated = $content.Replace($oldText, $newText)
                }
                else {
                    $index = $content.IndexOf($oldText, [System.StringComparison]::Ordinal)
                    $updated = $content.Substring(0, $index) + $newText + $content.Substring($index + $oldText.Length)
                }
                Write-Utf8NoBom -PathValue $targetPath -Content $updated -AppendMode:$false
                $applied += "replace_text:$($action.path)"
            }
            "delete_file" {
                if (Test-Path $targetPath) {
                    Remove-Item -Path $targetPath -Force
                }
                $applied += "delete_file:$($action.path)"
            }
            default {
                throw "Unsupported action type: $type"
            }
        }
    }
    return $applied
}

function Get-Status([string]$Text, $Parsed) {
    if (($Parsed -is [hashtable]) -and $Parsed.ContainsKey('status') -and $Parsed.status) {
        return ([string]$Parsed.status).ToLowerInvariant()
    }
    $lower = $Text.ToLowerInvariant()
    if ($lower -match 'pass/fail:\s*pass') { return 'pass' }
    if ($lower -match 'pass/fail:\s*fail') { return 'fail' }
    if ($lower -match '\bdefer\b') { return 'defer' }
    return 'success'
}

function Expand-Template([string]$Text, [hashtable]$Variables) {
    if ([string]::IsNullOrWhiteSpace($Text)) {
        return $Text
    }
    $expanded = $Text
    foreach ($key in $Variables.Keys) {
        $expanded = $expanded.Replace("{{${key}}}", [string]$Variables[$key])
    }
    return $expanded
}

function Resolve-NextStep([hashtable]$Step, [string]$Status) {
    $next = $null
    if ($Step.on -and $Step.on.ContainsKey($Status)) {
        $next = [string]$Step.on[$Status]
    }
    elseif ($Step.on -and $Step.on.ContainsKey("default")) {
        $next = [string]$Step.on.default
    }
    return $next
}

function Invoke-DirectMode {
    $resolvedSessionName = if ($SessionName) { $SessionName } else { "$Agent-$(Get-Date -Format 'yyyyMMdd-HHmmss')" }
    $sessionPath = Resolve-SessionPath $resolvedSessionName
    $session = Load-Session $sessionPath $resolvedSessionName
    $resultText = Invoke-AgentCall -AgentName $Agent -UserPrompt $Prompt -Session $session -Writable:$AllowEdits -ContextLabel "direct"
    $parsed = if ($AllowEdits) { Try-ParseJson $resultText } else { $null }
    if ($AllowEdits -and (-not $parsed)) {
        throw "Edit mode requires JSON output matching the edit contract."
    }
    $status = Get-Status -Text $resultText -Parsed $parsed
    $applied = @()
    if (($parsed -is [hashtable]) -and $parsed.ContainsKey('actions') -and $parsed.actions) {
        $applied = Apply-Actions $parsed.actions
    }

    $session.history += @(
        @{ role = "user"; content = $Prompt; agent = $Agent; timestamp = (Get-Date).ToString("o") },
        @{ role = "assistant"; content = $resultText; agent = $Agent; timestamp = (Get-Date).ToString("o") }
    )
    $session.results += @{
        agent   = $Agent
        status  = $status
        prompt  = $Prompt
        applied = $applied
        at      = (Get-Date).ToString("o")
    }
    Save-Session -Session $session -PathValue $sessionPath
    Write-Live "STATUS direct:$Agent => $status"

    if ($Raw) {
        [ordered]@{
            sessionPath = $sessionPath
            status      = $status
            applied     = $applied
            response    = if ($parsed) { $parsed } else { $resultText }
        } | ConvertTo-Json -Depth 25
        return
    }

    if ($parsed) {
        if (($parsed -is [hashtable]) -and $parsed.ContainsKey('output') -and $parsed.output) { $parsed.output }
        elseif (($parsed -is [hashtable]) -and $parsed.ContainsKey('summary') -and $parsed.summary) { $parsed.summary }
        else { $resultText }
        if ($applied.Count -gt 0) {
            "Applied actions: $($applied -join ', ')"
        }
    }
    else {
        $resultText
    }
    "Session: $sessionPath"
}

function Invoke-SequenceMode {
    $sequenceFullPath = [System.IO.Path]::GetFullPath((Join-Path $repoRoot $SequencePath))
    if (-not (Test-Path $sequenceFullPath)) {
        throw "Sequence file not found: $SequencePath"
    }

    $sequence = Get-Content -Raw -Path $sequenceFullPath | ConvertFrom-Json -AsHashtable
    $resolvedSessionName = if ($SessionName) { $SessionName } elseif ($sequence.sessionName) { [string]$sequence.sessionName } else { "sequence-$(Get-Date -Format 'yyyyMMdd-HHmmss')" }
    $sessionPath = Resolve-SessionPath $resolvedSessionName
    $session = Load-Session $sessionPath $resolvedSessionName

    $variables = @{}
    if ($sequence.variables) {
        foreach ($key in $sequence.variables.Keys) {
            $variables[$key] = [string]$sequence.variables[$key]
        }
    }
    $variables.repoRoot = $repoRoot
    $variables.sessionName = $resolvedSessionName

    $steps = @($sequence.steps)
    if ($steps.Count -eq 0) {
        throw "Sequence file has no steps."
    }

    $indexById = @{}
    for ($i = 0; $i -lt $steps.Count; $i++) {
        if ($steps[$i].id) {
            $indexById[[string]$steps[$i].id] = $i
        }
    }

    $index = 0
    $executed = 0
    while ($index -lt $steps.Count) {
        if ($executed -ge $MaxSteps) {
            throw "Sequence exceeded MaxSteps=$MaxSteps"
        }

        $step = $steps[$index]
        $executed++
        $stepId = [string]$step.id

        if (($step -is [hashtable]) -and $step.ContainsKey('parallel') -and $step.parallel) {
            Write-Live "STEP $stepId (parallel fan-out)"
            $branches = @($step.parallel)
            if ($branches.Count -eq 0) {
                throw "Step '$stepId' has an empty parallel block."
            }

            $branchResults = @()
            $preHistory = @($session.history)
            foreach ($branch in $branches) {
                $branchId = if ($branch.id) { [string]$branch.id } else { "branch-$($branchResults.Count + 1)" }
                $branchAgent = [string]$branch.agent
                $branchPrompt = Expand-Template -Text ([string]$branch.prompt) -Variables $variables
                $branchSession = @{
                    history = @($preHistory)
                }
                $branchText = Invoke-AgentCall -AgentName $branchAgent -UserPrompt $branchPrompt -Session $branchSession -Writable:$false -ContextLabel "$stepId/$branchId"
                $branchParsed = Try-ParseJson $branchText
                $branchStatus = Get-Status -Text $branchText -Parsed $branchParsed
                $branchSummary = if (($branchParsed -is [hashtable]) -and $branchParsed.ContainsKey('summary') -and $branchParsed.summary) { [string]$branchParsed.summary } else { $branchStatus }
                $branchOutput = if (($branchParsed -is [hashtable]) -and $branchParsed.ContainsKey('output') -and $branchParsed.output) { [string]$branchParsed.output } else { $branchText }
                $branchSummary = Truncate-Text -Text $branchSummary -MaxChars $MaxTextChars
                $branchOutput = Truncate-Text -Text $branchOutput -MaxChars $MaxTextChars

                $branchResults += @{
                    id      = $branchId
                    agent   = $branchAgent
                    status  = $branchStatus
                    summary = $branchSummary
                    output  = $branchOutput
                }
                Write-Live "STATUS ${stepId}/${branchId}:${branchAgent} => $branchStatus"
            }

            $aggregateStatus = "pass"
            if ($branchResults.Where({ $_.status -eq "error" }).Count -gt 0) {
                $aggregateStatus = "error"
            }
            elseif ($branchResults.Where({ $_.status -in @("fail", "defer", "repair-required") }).Count -gt 0) {
                $aggregateStatus = "fail"
            }
            elseif ($branchResults.Where({ $_.status -in @("success", "pass") }).Count -eq 0) {
                $aggregateStatus = "success"
            }

            $parallelJson = $branchResults | ConvertTo-Json -Depth 20
            $session.results += @{
                id       = $stepId
                mode     = "parallel"
                status   = $aggregateStatus
                branches = $branchResults
                at       = (Get-Date).ToString("o")
            }
            Save-Session -Session $session -PathValue $sessionPath

            $variables.lastStatus = $aggregateStatus
            $variables.lastSummary = "parallel:$aggregateStatus"
            $variables.lastOutput = $parallelJson
            $variables.parallelResultsJson = $parallelJson
            Write-Live "STATUS $stepId aggregate => $aggregateStatus"

            $next = Resolve-NextStep -Step $step -Status $aggregateStatus
            if ([string]::IsNullOrWhiteSpace($next) -or $next -eq "next") {
                $index++
            }
            elseif ($next -eq "stop") {
                break
            }
            elseif ($indexById.ContainsKey($next)) {
                $index = $indexById[$next]
            }
            else {
                throw "Unknown next step '$next' from step '$stepId'"
            }
            continue
        }

        $stepAgent = [string]$step.agent
        $stepPrompt = Expand-Template -Text ([string]$step.prompt) -Variables $variables
        Write-Live "STEP $stepId"
        $stepWritable = $false
        if (($step -is [hashtable]) -and $step.ContainsKey('allowEdits') -and $null -ne $step.allowEdits) {
            $stepWritable = [bool]$step.allowEdits
        }

        try {
            $resultText = Invoke-AgentCall -AgentName $stepAgent -UserPrompt $stepPrompt -Session $session -Writable:$stepWritable -ContextLabel $stepId
            $parsed = Try-ParseJson $resultText
            if ($stepWritable -and (-not $parsed)) {
                throw "Step '$stepId' requires JSON output matching the edit contract."
            }
            $status = Get-Status -Text $resultText -Parsed $parsed
            $applied = @()
            if (($parsed -is [hashtable]) -and $parsed.ContainsKey('actions') -and $parsed.actions) {
                $applied = Apply-Actions $parsed.actions
            }

            $session.history += @(
                @{ role = "user"; content = $stepPrompt; agent = $stepAgent; timestamp = (Get-Date).ToString("o") },
                @{ role = "assistant"; content = $resultText; agent = $stepAgent; timestamp = (Get-Date).ToString("o") }
            )
            $session.results += @{
                id      = $stepId
                agent   = $stepAgent
                status  = $status
                prompt  = $stepPrompt
                applied = $applied
                at      = (Get-Date).ToString("o")
            }
            Save-Session -Session $session -PathValue $sessionPath

            $variables.lastStatus = $status
            $variables.lastOutput = if (($parsed -is [hashtable]) -and $parsed.ContainsKey('output') -and $parsed.output) { [string]$parsed.output } else { $resultText }
            $variables.lastSummary = if (($parsed -is [hashtable]) -and $parsed.ContainsKey('summary') -and $parsed.summary) { [string]$parsed.summary } else { $status }
            $variables.lastOutput = Truncate-Text -Text $variables.lastOutput -MaxChars $MaxTextChars
            $variables.lastSummary = Truncate-Text -Text $variables.lastSummary -MaxChars $MaxTextChars
            Write-Live "STATUS ${stepId}:${stepAgent} => $status"

            $next = Resolve-NextStep -Step $step -Status $status

            if ([string]::IsNullOrWhiteSpace($next) -or $next -eq "next") {
                $index++
            }
            elseif ($next -eq "stop") {
                break
            }
            elseif ($indexById.ContainsKey($next)) {
                $index = $indexById[$next]
            }
            else {
                throw "Unknown next step '$next' from step '$stepId'"
            }
        }
        catch {
            $session.results += @{
                id     = $stepId
                agent  = $stepAgent
                status = "error"
                prompt = $stepPrompt
                error  = $_.Exception.Message
                at     = (Get-Date).ToString("o")
            }
            Save-Session -Session $session -PathValue $sessionPath

            $variables.lastStatus = "error"
            $variables.lastOutput = Truncate-Text -Text $_.Exception.Message -MaxChars $MaxTextChars
            $variables.lastSummary = "error"
            Write-Live "STATUS ${stepId}:${stepAgent} => error ($($_.Exception.Message))"

            $next = Resolve-NextStep -Step $step -Status "error"
            if ([string]::IsNullOrWhiteSpace($next)) {
                throw
            }

            if ($next -eq "stop") {
                break
            }
            elseif ($next -eq "next") {
                $index++
            }
            elseif ($indexById.ContainsKey($next)) {
                $index = $indexById[$next]
            }
            else {
                throw "Unknown error branch '$next' from step '$stepId'"
            }
        }
    }

    if ($Raw) {
        [ordered]@{
            sessionPath = $sessionPath
            executed    = $executed
            finalStatus = $variables.lastStatus
            lastOutput  = $variables.lastOutput
        } | ConvertTo-Json -Depth 25
        return
    }

    "Final status: $($variables.lastStatus)"
    if ($variables.lastOutput) {
        $variables.lastOutput
    }
    "Session: $sessionPath"
}

if (-not [string]::IsNullOrWhiteSpace($SequencePath)) {
    Invoke-SequenceMode
}
else {
    Invoke-DirectMode
}
