param(
  [string]$Org = "sloopygames",
  [ValidateSet("private", "public", "internal")]
  [string]$Visibility = "private",
  [string]$DefaultBranch = "main",
  [bool]$PushInitial = $true
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Write-Info {
  param([string]$Message)
  Write-Host "ℹ️  $Message" -ForegroundColor Cyan
}

function Write-Step {
  param([string]$Message)
  Write-Host "🔹 $Message" -ForegroundColor Blue
}

function Write-Ok {
  param([string]$Message)
  Write-Host "✅ $Message" -ForegroundColor Green
}

function Write-WarnStatus {
  param([string]$Message)
  Write-Host "⚠️  $Message" -ForegroundColor Yellow
}

function Write-FailStatus {
  param([string]$Message)
  Write-Host "❌ $Message" -ForegroundColor Red
}

function Require-Command {
  param([string]$Name)
  if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
    throw "Missing required command: $Name"
  }
}

function Ensure-Dir {
  param([string]$Path)
  if (-not (Test-Path $Path)) {
    New-Item -ItemType Directory -Path $Path -Force | Out-Null
  }
}

function Write-JsonFile {
  param(
    [string]$Path,
    [string]$JsonText
  )
  $JsonText | Set-Content -Path $Path -Encoding utf8
}

try {
  Write-Host ""
  Write-Info "AI system repo initializer starting..."

  Write-Step "Checking required tools"
  Require-Command git
  Require-Command gh
  Require-Command node
  Require-Command npm
  Write-Ok "Required tools are available (git, gh, node, npm)"

  $repoName = Split-Path -Leaf (Get-Location)
  if ([string]::IsNullOrWhiteSpace($repoName)) {
    throw "Could not determine repository name from current folder."
  }
  $repoSlug = "$Org/$repoName"
  Write-Info "Target repo: $repoSlug"

  if (-not (Test-Path ".git")) {
    Write-Step "No git repo found. Initializing local git repo"
    git init | Out-Null
    Write-Ok "Initialized local git repository"
  }
  else {
    Write-Ok "Local git repository detected"
  }

  $currentBranch = (git rev-parse --abbrev-ref HEAD 2>$null).Trim()
  if ([string]::IsNullOrWhiteSpace($currentBranch) -or $currentBranch -eq "HEAD") {
    git checkout -b $DefaultBranch | Out-Null
    Write-Ok "Created default branch '$DefaultBranch'"
  }
  elseif ($currentBranch -ne $DefaultBranch) {
    git branch -M $DefaultBranch | Out-Null
    Write-Ok "Renamed current branch to '$DefaultBranch'"
  }
  else {
    Write-Ok "Default branch already '$DefaultBranch'"
  }

  Write-Step "Configuring PowerShell script execution policy"
  try {
    Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force
    Write-Ok "Set CurrentUser execution policy to RemoteSigned"
  }
  catch {
    Write-WarnStatus "Could not set CurrentUser execution policy. Continuing with process scope only."
  }
  Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
  Write-Ok "Set process execution policy to Bypass"

  Write-Step "Checking GitHub authentication"
  gh auth status -h github.com *> $null
  if ($LASTEXITCODE -ne 0) {
    Write-Step "Not authenticated. Logging in with required scopes"
    gh auth login -h github.com -w -s "repo,read:org,workflow"
    Write-Ok "GitHub authentication completed"
  }
  else {
    Write-Step "Authenticated. Refreshing token scopes"
    gh auth refresh -h github.com -s repo -s read:org -s workflow | Out-Null
    Write-Ok "GitHub token scopes refreshed"
  }

  Write-Step "Validating org access for $Org"
  gh api "orgs/$Org" *> $null
  if ($LASTEXITCODE -ne 0) {
    throw "Authenticated account does not have access to org $Org."
  }
  Write-Ok "Org access confirmed for $Org"

  Write-Step "Ensuring repository exists on GitHub"
  gh repo view $repoSlug *> $null
  if ($LASTEXITCODE -ne 0) {
    Write-Step "Creating GitHub repo $repoSlug"
    gh repo create $repoSlug --$Visibility --source . --remote origin | Out-Null
    Write-Ok "Created repository $repoSlug"
  }
  else {
    Write-Ok "Repository already exists: $repoSlug"
    git remote get-url origin *> $null
    if ($LASTEXITCODE -ne 0) {
      git remote add origin "git@github.com:$repoSlug.git"
      Write-Ok "Added origin remote"
    }
    else {
      Write-Ok "Origin remote already configured"
    }
  }

  Write-Step "Ensuring Copilot and VS Code configuration files"
  Ensure-Dir ".github"
  Ensure-Dir ".vscode"

  $copilotInstructionsPath = ".github/copilot-instructions.md"
  if (-not (Test-Path $copilotInstructionsPath)) {
    @"
# Copilot Instructions

This repository follows governed AI mutation flow.

- Mutate candidate runtime paths only.
- Never mutate trusted release runtime directly.
- Run evidence and audit before promotion.
- Preserve validator strength.
- Keep changes deterministic and minimal.
"@ | Set-Content -Path $copilotInstructionsPath -Encoding utf8
    Write-Ok "Created $copilotInstructionsPath"
  }
  else {
    Write-Ok "$copilotInstructionsPath already exists"
  }

  $settingsPath = ".vscode/settings.json"
  if (-not (Test-Path $settingsPath)) {
    Write-JsonFile -Path $settingsPath -JsonText @"
{
  "github.copilot.chat.codeGeneration.useInstructionFiles": true
}
"@
    Write-Ok "Created $settingsPath"
  }
  else {
    Write-Ok "$settingsPath already exists"
  }



  Write-Step "Creating Copilot wrapper scripts"
  Ensure-Dir "scripts"

  $copilotRunPath = "scripts/copilot-run.ps1"
  @'
param(
  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]]$Args
)

$copilotCmd = if ($IsWindows) { "copilot.bat" } else { "copilot" }
& $copilotCmd `
  --allow-all-tools `
  --no-ask-user `
  --silent `
  --output-format json `
  --allow-tool='write' `
  --allow-tool='shell' `
  --deny-tool='shell(git push)' `
  --deny-tool='shell(rm)' `
  @Args
'@ | Set-Content -Path $copilotRunPath -Encoding utf8
  Write-Ok "Created $copilotRunPath"

  $copilotRunCmdPath = "copilot-run.cmd"
  @'
@echo off
copilot.bat ^
  --allow-all-tools ^
  --no-ask-user ^
  --silent ^
  --output-format json ^
  --allow-tool=write ^
  --allow-tool=shell ^
  --deny-tool="shell(git push)" ^
  --deny-tool="shell(rm)" ^
  %*
'@ | Set-Content -Path $copilotRunCmdPath -Encoding ascii
  Write-Ok "Created $copilotRunCmdPath"

  if ($PushInitial) {
    Write-Step "Preparing initial commit and push"
    if (-not (Test-Path "README.md")) {
      "Initialized for governed AI system workflow." | Set-Content -Path "README.md" -Encoding utf8
      Write-Ok "Created README.md"
    }

    $status = git status --porcelain
    if (-not [string]::IsNullOrWhiteSpace($status)) {
      git add -A
      git commit -m "chore: initialize repository for governed AI system" | Out-Null
      Write-Ok "Created initialization commit"
    }
    else {
      Write-Info "No local changes to commit"
    }

    git push -u origin $DefaultBranch
    Write-Ok "Pushed $DefaultBranch to origin"
  }
  else {
    Write-Info "PushInitial is false. Skipping commit/push."
  }

  Write-Host ""
  Write-Info "Initialization complete. Repo: $repoSlug | Branch: $DefaultBranch | Visibility: $Visibility"
  Write-Host "SUCCESS!" -ForegroundColor Green
}
catch {
  Write-Host ""
  Write-FailStatus "Initialization failed: $($_.Exception.Message)"
  Write-Host "Recommended solution: verify GitHub org access, run 'gh auth login -h github.com -w -s repo,read:org,workflow', then rerun the script from the target repo root." -ForegroundColor Yellow
  Write-Host "FAIL - Recommended solution: verify org access/scopes and rerun from repo root." -ForegroundColor Red
  exit 1
}
