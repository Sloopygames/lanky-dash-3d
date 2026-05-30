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
