param(
    [string]$SharedFolder = "./shared/inbox",
    [string]$OutputFolder = "./shared/reviews",
    [string]$RunScriptPath = "./scripts/run-agent-chat.ps1",
    [string]$X01PromptPath = "./prompts/X01-Audit JSON.md",
    [string]$AgentB = "exploration-operator",
    [string]$AgentC = "governance-auditor",
    [ValidateSet("api", "cli", "auto")]
    [string]$Backend = "api",
    [string]$Model = "auto",
    [string]$SessionPrefix = "refine-shared-watch",
    [int]$DebounceMs = 800,
    [int]$SharedContextFiles = 6,
    [int]$SharedContextMaxCharsPerFile = 1200,
    [switch]$Live,
    [int]$MaxHistoryItems = 8,
    [int]$MaxTextChars = 1200,
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

function Ensure-Directory([string]$PathValue) {
    if (-not (Test-Path $PathValue)) {
        New-Item -ItemType Directory -Path $PathValue -Force | Out-Null
    }
}

function Read-TextWithRetries([string]$PathValue, [int]$Attempts = 5) {
    for ($i = 1; $i -le $Attempts; $i++) {
        try {
            return Get-Content -Raw -Path $PathValue
        }
        catch {
            if ($i -eq $Attempts) {
                throw
            }
            [System.Threading.Thread]::Sleep(120)
        }
    }
    throw "Unable to read file after $Attempts attempts: $PathValue"
}

function Write-Utf8Json([string]$PathValue, $ObjectValue) {
    $dir = Split-Path -Parent $PathValue
    Ensure-Directory $dir
    $json = $ObjectValue | ConvertTo-Json -Depth 25
    $encoding = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($PathValue, $json, $encoding)
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

    throw "Unable to parse JSON result from run-agent-chat output."
}

function Get-LatestSharedContextText {
    $allFiles = New-Object System.Collections.Generic.List[System.IO.FileInfo]
    foreach ($folder in @($script:AbsSharedFolder, $script:AbsOutputFolder)) {
        if (-not (Test-Path $folder)) { continue }
        foreach ($f in (Get-ChildItem -Path $folder -Filter *.json -File -ErrorAction SilentlyContinue)) {
            $allFiles.Add($f)
        }
    }

    if ($allFiles.Count -eq 0) {
        return "No shared JSON context is available yet."
    }

    $latest = @($allFiles | Sort-Object LastWriteTimeUtc -Descending | Select-Object -First $SharedContextFiles)
    $sections = New-Object System.Collections.Generic.List[string]
    foreach ($f in $latest) {
        $raw = Get-Content -Raw -Path $f.FullName
        if ($raw.Length -gt $SharedContextMaxCharsPerFile) {
            $raw = $raw.Substring(0, $SharedContextMaxCharsPerFile) + "`n...[truncated]..."
        }
        $sections.Add(("File: {0}`n{1}" -f $f.FullName, $raw))
    }

    return ($sections -join "`n`n")
}

function Invoke-AgentAudit([string]$AgentName, [string]$PromptText) {
    $args = @(
        "-File", $script:AbsRunScript,
        "-Agent", $AgentName,
        "-Prompt", $PromptText,
        "-Backend", $Backend,
        "-Model", $Model,
        "-SessionName", "$SessionPrefix-$AgentName",
        "-MaxHistoryItems", [string]$MaxHistoryItems,
        "-MaxTextChars", [string]$MaxTextChars,
        "-MaxApiRetries", [string]$MaxApiRetries,
        "-RetryDelaySeconds", [string]$RetryDelaySeconds,
        "-Raw"
    )
    if ($Live) {
        $args += "-Live"
    }

    $raw = & pwsh @args
    $rawText = ($raw | Out-String)
    if ($LASTEXITCODE -ne 0) {
        throw "run-agent-chat failed for agent '$AgentName' with exit code $LASTEXITCODE"
    }

    return (Parse-RunnerJson -RawText $rawText)
}

function Process-SharedJson([string]$FullPath) {
    if (-not (Test-Path $FullPath)) {
        return
    }
    if (-not $FullPath.EndsWith(".json", [System.StringComparison]::OrdinalIgnoreCase)) {
        return
    }

    $lastWrite = (Get-Item -LiteralPath $FullPath).LastWriteTimeUtc
    $ticks = $lastWrite.Ticks
    if ($script:LastWriteByPath.ContainsKey($FullPath) -and $script:LastWriteByPath[$FullPath] -eq $ticks) {
        return
    }

    $nowMs = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
    if ($script:LastProcessedMsByPath.ContainsKey($FullPath)) {
        $delta = $nowMs - $script:LastProcessedMsByPath[$FullPath]
        if ($delta -lt $DebounceMs) {
            return
        }
    }

    $script:LastWriteByPath[$FullPath] = $ticks
    $script:LastProcessedMsByPath[$FullPath] = $nowMs

    $jsonBody = Read-TextWithRetries -PathValue $FullPath
    $relativePath = [System.IO.Path]::GetRelativePath((Get-Location).Path, $FullPath)
    $sourceStamp = (Get-Date).ToUniversalTime().ToString("o")

    Write-Host "Processing shared JSON update: $relativePath"

    $sharedContext = Get-LatestSharedContextText
    $basePrompt = @"
$script:X01Prompt

Source file: $relativePath
Captured at UTC: $sourceStamp

JSON object content:
$jsonBody

Latest shared JSON context (inbox/reviews):
$sharedContext
"@

    foreach ($agentName in @($AgentB, $AgentC)) {
        $result = Invoke-AgentAudit -AgentName $agentName -PromptText $basePrompt
        $stamp = Get-Date
        $fileBase = [System.IO.Path]::GetFileNameWithoutExtension($FullPath)
        $outName = "{0:yyyyMMdd-HHmmss-fff}_{1}_{2}.json" -f $stamp, $fileBase, $agentName
        $outPath = Join-Path $script:AbsOutputFolder $outName

        $payload = [ordered]@{
            eventType       = "shared-json-review"
            sourceFile      = $relativePath
            sourceTimestamp = $sourceStamp
            reviewedBy      = $agentName
            status          = $result.status
            sessionPath     = $result.sessionPath
            response        = $result.response
            writtenUtc      = $stamp.ToUniversalTime().ToString("o")
        }

        Write-Utf8Json -PathValue $outPath -ObjectValue $payload
        Write-Host "Wrote review JSON: $outPath"
    }
}

$script:AbsSharedFolder = Resolve-AbsolutePath $SharedFolder
$script:AbsOutputFolder = Resolve-AbsolutePath $OutputFolder
$script:AbsRunScript = Resolve-AbsolutePath $RunScriptPath
$script:X01Prompt = (Get-Content -Raw -Path (Resolve-AbsolutePath $X01PromptPath)).Trim()
$script:LastWriteByPath = @{}
$script:LastProcessedMsByPath = @{}

Ensure-Directory $script:AbsSharedFolder
Ensure-Directory $script:AbsOutputFolder

$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $script:AbsSharedFolder
$watcher.Filter = "*.json"
$watcher.IncludeSubdirectories = $false
$watcher.NotifyFilter = [System.IO.NotifyFilters]'FileName, LastWrite, CreationTime, Size'
$watcher.EnableRaisingEvents = $true

$createdId = "SharedJsonCreated"
$changedId = "SharedJsonChanged"
Register-ObjectEvent -InputObject $watcher -EventName Created -SourceIdentifier $createdId | Out-Null
Register-ObjectEvent -InputObject $watcher -EventName Changed -SourceIdentifier $changedId | Out-Null

Write-Host "Watching $script:AbsSharedFolder for JSON updates."
Write-Host "Agent B: $AgentB"
Write-Host "Agent C: $AgentC"
Write-Host "Press Ctrl+C to stop."

try {
    while ($true) {
        $evt = Wait-Event -Timeout 2
        if ($null -eq $evt) {
            continue
        }

        if ($evt.SourceIdentifier -notin @($createdId, $changedId)) {
            Remove-Event -EventIdentifier $evt.EventIdentifier -ErrorAction SilentlyContinue
            continue
        }

        try {
            $path = [string]$evt.SourceEventArgs.FullPath
            Remove-Event -EventIdentifier $evt.EventIdentifier -ErrorAction SilentlyContinue
            Process-SharedJson -FullPath $path
        }
        catch {
            Write-Warning "Failed to process shared JSON event: $($_.Exception.Message)"
        }
    }
}
finally {
    Unregister-Event -SourceIdentifier $createdId -ErrorAction SilentlyContinue
    Unregister-Event -SourceIdentifier $changedId -ErrorAction SilentlyContinue
    $watcher.Dispose()
}