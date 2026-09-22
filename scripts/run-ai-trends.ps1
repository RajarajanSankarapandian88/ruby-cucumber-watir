[CmdletBinding()]
param(
  [ValidateSet("chrome", "edge")]
  [string]$Browser = "chrome",
  [bool]$Headless = $true
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$env:Path = "C:\Ruby40-x64\bin;$env:Path"
$env:BROWSER = $Browser
$env:HEADLESS = $Headless.ToString().ToLowerInvariant()

Set-Location -LiteralPath $ProjectRoot
& bundle exec cucumber --profile allure features/ai_trends.feature
if ($LASTEXITCODE -ne 0) { throw "Cucumber failed with exit code $LASTEXITCODE" }

Write-Host "Results saved to allure-results and artifacts."
Write-Host "Run .\scripts\open-allure-report.ps1 to view the report."
