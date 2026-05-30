param(
    [Parameter(Mandatory = $true)]
    [string]$Agent,

    [Parameter(Mandatory = $true)]
    [string]$Prompt,

    [string]$Model = "gpt-4o-mini",
    [string]$Endpoint = "",
    [switch]$Raw
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$agentFile = Join-Path $repoRoot ".github/agents/$Agent.agent.md"

if (-not (Test-Path $agentFile)) {
    $agentDir = Join-Path $repoRoot ".github/agents"
    $available = @()
    if (Test-Path $agentDir) {
        $available = Get-ChildItem $agentDir -Filter "*.agent.md" | ForEach-Object { $_.BaseName -replace "\.agent$", "" }
    }
    $availableText = if ($available.Count -gt 0) { $available -join ", " } else { "(none found)" }
    throw "Agent file not found: $agentFile`nAvailable agents: $availableText"
}

$token = if ($env:GITHUB_TOKEN) { $env:GITHUB_TOKEN } elseif ($env:GH_TOKEN) { $env:GH_TOKEN } else { "" }
if ([string]::IsNullOrWhiteSpace($token)) {
    throw "Missing token. Set GITHUB_TOKEN (or GH_TOKEN) with GitHub Models access."
}

if ([string]::IsNullOrWhiteSpace($Endpoint)) {
    if ($env:GITHUB_MODELS_ENDPOINT) {
        $Endpoint = $env:GITHUB_MODELS_ENDPOINT
    }
    else {
        $Endpoint = "https://models.inference.ai.azure.com/chat/completions"
    }
}

$agentSpec = Get-Content -Raw -Path $agentFile

# Strip YAML frontmatter for cleaner prompt body while preserving behavior text.
$agentBody = $agentSpec
if ($agentSpec.StartsWith("---")) {
    $frontMatterEnd = [regex]::Match($agentSpec, "(?s)^---\r?\n.*?\r?\n---\r?\n")
    if ($frontMatterEnd.Success) {
        $agentBody = $agentSpec.Substring($frontMatterEnd.Length)
    }
}

$systemText = @"
You are running the local repository agent profile '$Agent'.
Follow this profile as your governing instructions.

$agentBody
"@

$payload = @{
    model       = $Model
    messages    = @(
        @{ role = "system"; content = $systemText },
        @{ role = "user"; content = $Prompt }
    )
    temperature = 0.6
} | ConvertTo-Json -Depth 10

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type"  = "application/json"
}

$response = Invoke-RestMethod -Method Post -Uri $Endpoint -Headers $headers -Body $payload

if ($Raw) {
    $response | ConvertTo-Json -Depth 10
    exit 0
}

if ($null -eq $response.choices -or $response.choices.Count -eq 0) {
    throw "No choices returned from endpoint."
}

$content = $response.choices[0].message.content
if ($content -is [System.Array]) {
    ($content | ForEach-Object {
        if ($_.text) { $_.text } else { $_ | ConvertTo-Json -Depth 5 }
    }) -join "`n"
}
else {
    $content
}
