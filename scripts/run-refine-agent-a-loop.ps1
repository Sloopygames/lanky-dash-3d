param(
    [string]$AgentA = "exploration-operator",
    [ValidateSet("api", "cli", "auto")]
    [string]$Backend = "api",
    [string]$Model = "auto",
    [string]$SessionName = "refine-agent-a-$(Get-Date -Format 'yyyyMMdd-HHmmss')",
    [string]$RunScriptPath = "./scripts/run-agent-chat.ps1",
    [string]$PromptFolder = "./prompts",
    [string]$SharedFolder = "./shared/inbox",
    [string]$ReviewFolder = "./shared/reviews",
    [int]$MaxLoops = 3,
    [switch]$EnableEditsInA03 = $true,
    [switch]$CommitAndPushAfterA03 = $true,
    [string]$GitRemote = "origin",
    [switch]$Live,
    [bool]$StreamInnerLiveOutput = $true,
    [int]$MaxHistoryItems = 8,
    [int]$MaxTextChars = 4000,
    [int]$SharedContextFiles = 6,
    [int]$SharedContextMaxCharsPerFile = 1200,
    [int]$MaxApiRetries = 8,
    [int]$RetryDelaySeconds = 12
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Resolve-AbsolutePath([string]$PathValue) {
    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return [System.IO.Path]::GetFullPath($PathValue)
    }
    return [System.IO.Path]::GetFullPath((Join-Path (Get-Location) $PathValue))
}

function Read-PromptFile([string]$PathValue) {
    if (-not (Test-Path $PathValue)) {
        throw "Prompt file not found: $PathValue"
    }
    return (Get-Content -Raw -Path $PathValue).Trim()
}

function Write-Utf8Json([string]$PathValue, $ObjectValue) {
    $dir = Split-Path -Parent $PathValue
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    $json = $ObjectValue | ConvertTo-Json -Depth 25
    $encoding = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($PathValue, $json, $encoding)
}

function Is-GitRepo {
    & git rev-parse --is-inside-work-tree *> $null
    return ($LASTEXITCODE -eq 0)
}

function Get-CurrentGitBranch {
    $branch = (& git rev-parse --abbrev-ref HEAD 2>$null | Out-String).Trim()
    if ([string]::IsNullOrWhiteSpace($branch)) {
        throw "Unable to determine current git branch."
    }
    return $branch
}

function Get-TrackedPathsFromApplied($AppliedList) {
    $paths = New-Object System.Collections.Generic.List[string]
    foreach ($item in @($AppliedList)) {
        $text = [string]$item
        if ([string]::IsNullOrWhiteSpace($text)) { continue }
        $parts = $text.Split(':', 2)
        if ($parts.Count -lt 2) { continue }
        $path = $parts[1].Trim()
        if (-not [string]::IsNullOrWhiteSpace($path)) {
            $paths.Add($path)
        }
    }
    return @($paths | Select-Object -Unique)
}

function Commit-And-PushImplementation([int]$Iteration, $AppliedList) {
    if (-not $CommitAndPushAfterA03) {
        return [ordered]@{ committed = $false; pushed = $false; note = "Commit/push disabled" }
    }
    if (-not (Is-GitRepo)) {
        return [ordered]@{ committed = $false; pushed = $false; note = "Not a git repository" }
    }

    $paths = Get-TrackedPathsFromApplied -AppliedList $AppliedList
    if ($paths.Count -eq 0) {
        return [ordered]@{ committed = $false; pushed = $false; note = "No applied file paths from A03" }
    }

    & git add -- @paths
    if ($LASTEXITCODE -ne 0) {
        throw "git add failed for A03 iteration $Iteration"
    }

    $staged = (& git diff --cached --name-only | Out-String).Trim()
    if ([string]::IsNullOrWhiteSpace($staged)) {
        return [ordered]@{ committed = $false; pushed = $false; note = "No staged changes after git add" }
    }

    $commitMessage = "Agent A implementation iteration $Iteration ($SessionName)"
    & git commit -m $commitMessage
    if ($LASTEXITCODE -ne 0) {
        throw "git commit failed for A03 iteration $Iteration"
    }

    $branch = Get-CurrentGitBranch
    $upstream = (& git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>$null | Out-String).Trim()
    if ([string]::IsNullOrWhiteSpace($upstream)) {
        & git push -u $GitRemote $branch
    }
    else {
        & git push
    }
    if ($LASTEXITCODE -ne 0) {
        throw "git push failed for A03 iteration $Iteration"
    }

    return [ordered]@{ committed = $true; pushed = $true; branch = $branch; staged = $staged }
}

function Get-SharedContextText {
    $folders = @((Resolve-AbsolutePath $SharedFolder), (Resolve-AbsolutePath $ReviewFolder))
    $files = New-Object System.Collections.Generic.List[System.IO.FileInfo]

    foreach ($folder in $folders) {
        if (-not (Test-Path $folder)) { continue }
        foreach ($f in (Get-ChildItem -Path $folder -Filter *.json -File -ErrorAction SilentlyContinue)) {
            $files.Add($f)
        }
    }

    if ($files.Count -eq 0) {
        return "No shared JSON context is available yet."
    }

    $latest = @($files | Sort-Object LastWriteTimeUtc -Descending | Select-Object -First $SharedContextFiles)
    $blocks = New-Object System.Collections.Generic.List[string]

    foreach ($f in $latest) {
        $raw = Get-Content -Raw -Path $f.FullName
        if ($raw.Length -gt $SharedContextMaxCharsPerFile) {
            $raw = $raw.Substring(0, $SharedContextMaxCharsPerFile) + "`n...[truncated]..."
        }
        $blocks.Add(("File: {0}`n{1}" -f $f.FullName, $raw))
    }

    return ($blocks -join "`n`n")
}

function Build-StepPrompt([string]$BasePrompt, [int]$Iteration) {
    $sharedContext = Get-SharedContextText
    return @"
Loop iteration: $Iteration / $MaxLoops

$BasePrompt

Shared JSON context (latest files from inbox/reviews):
$sharedContext
"@
}

function Parse-RunnerJson([string]$RawText) {
    $trimmed = $RawText.Trim()
    try {
        return ($trimmed | ConvertFrom-Json -AsHashtable)
    }
    catch {
    }

    $firstBrace = $trimmed.IndexOf('{')
    $lastBrace = $trimmed.LastIndexOf('}')
    if ($firstBrace -ge 0 -and $lastBrace -gt $firstBrace) {
        $candidate = $trimmed.Substring($firstBrace, $lastBrace - $firstBrace + 1)
        try {
            return ($candidate | ConvertFrom-Json -AsHashtable)
        }
        catch {
        }
    }

    $sample = Truncate-Text -Text $trimmed -MaxChars 800
    throw "Unable to parse JSON result from run-agent-chat output. Sample:`n$sample"
}

function Truncate-Text([string]$Text, [int]$MaxChars = 1200) {
    if ([string]::IsNullOrWhiteSpace($Text)) {
        return $Text
    }
    if ($Text.Length -le $MaxChars) {
        return $Text
    }
    return $Text.Substring(0, $MaxChars) + "`n...[truncated]..."
}

function Invoke-RunnerCommand([string[]]$ArgsList) {
    if ($Live -and $StreamInnerLiveOutput) {
        $lines = New-Object System.Collections.Generic.List[string]
        & pwsh @ArgsList 2>&1 | ForEach-Object {
            $line = [string]$_
            Write-Host $line
            $lines.Add($line)
        }
        $exitCode = $LASTEXITCODE
        return [ordered]@{
            ExitCode = $exitCode
            RawText  = ($lines -join "`n")
        }
    }

    $raw = & pwsh @ArgsList
    $exitCode = $LASTEXITCODE
    return [ordered]@{
        ExitCode = $exitCode
        RawText  = ($raw | Out-String)
    }
}

function Get-NeedImproveFromObject($ObjectValue) {
    if ($null -eq $ObjectValue) {
        return $null
    }

    $candidateKeys = @("needImprove", "needsImprove", "doWeNeedToImprove", "improve")
    foreach ($key in $candidateKeys) {
        if ($ObjectValue.ContainsKey($key)) {
            $value = $ObjectValue[$key]
            if ($value -is [bool]) { return [bool]$value }
            if ($value) {
                $text = ([string]$value).Trim().ToLowerInvariant()
                if ($text -eq "yes") { return $true }
                if ($text -eq "no") { return $false }
            }
        }
    }

    return $null
}

function Test-NeedImprove([string]$ResponseText) {
    if ([string]::IsNullOrWhiteSpace($ResponseText)) {
        return $true
    }

    $trimmed = $ResponseText.Trim()

    try {
        $parsed = $trimmed | ConvertFrom-Json -AsHashtable
        $jsonDecision = Get-NeedImproveFromObject -ObjectValue $parsed
        if ($null -ne $jsonDecision) {
            return $jsonDecision
        }
    }
    catch {
    }

    $line3 = [regex]::Match($trimmed, '(?im)^\s*3[\.|\)]?\s*(?<answer>.+)$')
    if ($line3.Success) {
        $answer = $line3.Groups["answer"].Value.ToLowerInvariant()
        if ($answer -match '\bno\b') { return $false }
        if ($answer -match '\byes\b') { return $true }
    }

    $inline = [regex]::Match($trimmed, '(?im)do\s+we\s+need\s+to\s+improve\??\s*[:\-]?\s*(?<answer>yes|no)\b')
    if ($inline.Success) {
        return $inline.Groups["answer"].Value.ToLowerInvariant() -eq "yes"
    }

    return $true
}

function Invoke-AgentStep([string]$StepId, [string]$StepPrompt, [int]$Iteration, [bool]$Writable = $false) {
    $absRunScript = Resolve-AbsolutePath $RunScriptPath
    $effectivePrompt = $StepPrompt
    if ($Writable) {
        $effectivePrompt = @"
$StepPrompt

Implementation contract for this step:
- Make real repository file edits when needed.
- Return valid JSON actions only.
- Do not return markdown fences.
"@
    }

    $args = @(
        "-File", $absRunScript,
        "-Agent", $AgentA,
        "-Prompt", $effectivePrompt,
        "-Backend", $Backend,
        "-Model", $Model,
        "-SessionName", $SessionName,
        "-MaxHistoryItems", [string]$MaxHistoryItems,
        "-MaxTextChars", [string]$MaxTextChars,
        "-MaxApiRetries", [string]$MaxApiRetries,
        "-RetryDelaySeconds", [string]$RetryDelaySeconds,
        "-Raw"
    )
    if ($Live) {
        $args += "-Live"
    }
    if ($Writable) {
        $args += "-AllowEdits"
    }

    Write-Host "Running $StepId (iteration $Iteration) with agent '$AgentA'..."
    $invoke = Invoke-RunnerCommand -ArgsList $args
    $rawText = [string]$invoke.RawText
    $exitCode = [int]$invoke.ExitCode
    if ($exitCode -ne 0 -and $Writable) {
        Write-Warning "Writable step '$StepId' failed once. Retrying with stricter JSON-only reminder."
        $retryPrompt = @"
$effectivePrompt

Retry requirement:
Return JSON only with status/summary/output/actions.
"@
        $retryArgs = @(
            "-File", $absRunScript,
            "-Agent", $AgentA,
            "-Prompt", $retryPrompt,
            "-Backend", $Backend,
            "-Model", $Model,
            "-SessionName", $SessionName,
            "-MaxHistoryItems", [string]$MaxHistoryItems,
            "-MaxTextChars", [string]$MaxTextChars,
            "-MaxApiRetries", [string]$MaxApiRetries,
            "-RetryDelaySeconds", [string]$RetryDelaySeconds,
            "-Raw",
            "-AllowEdits"
        )
        if ($Live) {
            $retryArgs += "-Live"
        }
        $retryInvoke = Invoke-RunnerCommand -ArgsList $retryArgs
        $rawText = [string]$retryInvoke.RawText
        $exitCode = [int]$retryInvoke.ExitCode
    }

    if ($exitCode -ne 0) {
        $tail = Truncate-Text -Text $rawText -MaxChars 1200
        throw "run-agent-chat failed for step '$StepId' with exit code $exitCode. Output: $tail"
    }

    $parsed = Parse-RunnerJson -RawText $rawText
    $responseText = if ($parsed.ContainsKey("response")) { [string]$parsed.response } else { "" }
    $status = if ($parsed.ContainsKey("status")) { [string]$parsed.status } else { "success" }
    $applied = @()
    if ($parsed.ContainsKey("applied") -and $null -ne $parsed.applied) {
        $applied = @($parsed.applied)
    }

    $timestamp = Get-Date
    $event = [ordered]@{
        eventType    = "agent-a-step"
        agent        = $AgentA
        sessionName  = $SessionName
        step         = $StepId
        iteration    = $Iteration
        status       = $status
        timestampUtc = $timestamp.ToUniversalTime().ToString("o")
        prompt       = $StepPrompt
        response     = $responseText
        writable     = $Writable
        applied      = $applied
    }

    $safeStep = $StepId -replace '[^a-zA-Z0-9\-_]', "_"
    $fileName = "{0:yyyyMMdd-HHmmss-fff}_{1}.json" -f $timestamp, $safeStep
    $targetPath = Join-Path (Resolve-AbsolutePath $SharedFolder) $fileName
    Write-Utf8Json -PathValue $targetPath -ObjectValue $event
    Write-Host "Wrote shared JSON: $targetPath"

    return [ordered]@{
        status       = $status
        response     = $responseText
        sharedPath   = $targetPath
        timestampUtc = $event.timestampUtc
        applied      = $applied
    }
}

if ($MaxLoops -lt 1) {
    throw "MaxLoops must be >= 1"
}

$promptRoot = Resolve-AbsolutePath $PromptFolder
$a01Path = Join-Path $promptRoot "A01-Create Tests.md"
$a02Path = Join-Path $promptRoot "A02-Create Plans.md"
$a03Path = Join-Path $promptRoot "A03-Execute Plans.md"
$a04Path = Join-Path $promptRoot "A04-Refine Plans.md"

$a01Prompt = Read-PromptFile -PathValue $a01Path
$a02Prompt = Read-PromptFile -PathValue $a02Path
$a03Prompt = Read-PromptFile -PathValue $a03Path
$a04Prompt = Read-PromptFile -PathValue $a04Path

$null = New-Item -ItemType Directory -Path (Resolve-AbsolutePath $SharedFolder) -Force
$null = New-Item -ItemType Directory -Path (Resolve-AbsolutePath $ReviewFolder) -Force

$runSummary = [ordered]@{
    sessionName = $SessionName
    agent       = $AgentA
    maxLoops    = $MaxLoops
    startedUtc  = (Get-Date).ToUniversalTime().ToString("o")
    steps       = @()
    loopExitedEarly = $false
    stopReason  = ""
    gitEnabled = $CommitAndPushAfterA03
}

$runSummary.steps += Invoke-AgentStep -StepId "A01" -StepPrompt (Build-StepPrompt -BasePrompt $a01Prompt -Iteration 0) -Iteration 0
$runSummary.steps += Invoke-AgentStep -StepId "A02" -StepPrompt (Build-StepPrompt -BasePrompt $a02Prompt -Iteration 0) -Iteration 0

for ($i = 1; $i -le $MaxLoops; $i++) {
    $a03Result = Invoke-AgentStep -StepId "A03" -StepPrompt (Build-StepPrompt -BasePrompt $a03Prompt -Iteration $i) -Iteration $i -Writable:$EnableEditsInA03
    $runSummary.steps += $a03Result

    $gitResult = Commit-And-PushImplementation -Iteration $i -AppliedList $a03Result.applied
    $runSummary.steps += [ordered]@{
        status       = if ($gitResult.pushed) { "success" } else { "skipped" }
        response     = ("git commit/push: {0}" -f ($gitResult | ConvertTo-Json -Depth 8 -Compress))
        sharedPath   = ""
        timestampUtc = (Get-Date).ToUniversalTime().ToString("o")
        step         = "A03-GIT"
        iteration    = $i
        applied      = @()
    }

    $a04Result = Invoke-AgentStep -StepId "A04" -StepPrompt (Build-StepPrompt -BasePrompt $a04Prompt -Iteration $i) -Iteration $i
    $runSummary.steps += $a04Result

    $needImprove = Test-NeedImprove -ResponseText ([string]$a04Result.response)
    if (-not $needImprove) {
        $runSummary.loopExitedEarly = $true
        $runSummary.stopReason = "A04 answered no to improvement on iteration $i"
        Write-Host "A04 indicates no further improvements are needed. Stopping loop early at iteration $i."
        break
    }
}

if ([string]::IsNullOrWhiteSpace($runSummary.stopReason)) {
    $runSummary.stopReason = "Reached MaxLoops ($MaxLoops)"
}

$runSummary.endedUtc = (Get-Date).ToUniversalTime().ToString("o")
$summaryPath = Join-Path (Resolve-AbsolutePath $SharedFolder) ("{0:yyyyMMdd-HHmmss-fff}_A00-run-summary.json" -f (Get-Date))
Write-Utf8Json -PathValue $summaryPath -ObjectValue $runSummary

Write-Host "Run complete."
Write-Host "Session: $SessionName"
Write-Host "Summary JSON: $summaryPath"
Write-Host "Stop reason: $($runSummary.stopReason)"