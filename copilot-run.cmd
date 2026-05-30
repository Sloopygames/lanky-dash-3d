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
