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
$AllureResults = Join-Path $ProjectRoot "allure-results"
if (Test-Path -LiteralPath $AllureResults) {
  Remove-Item -LiteralPath $AllureResults -Recurse -Force
}
New-Item -ItemType Directory -Path $AllureResults -Force | Out-Null

& bundle exec cucumber --profile external features/ai_trends.feature
if ($LASTEXITCODE -ne 0) { throw "Cucumber failed with exit code $LASTEXITCODE" }

Write-Host "Results saved to allure-results and artifacts."
Write-Host "Run .\scripts\open-allure-report.ps1 to view the report."
