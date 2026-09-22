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
& "$PSScriptRoot\run-cucumber.ps1" -Profile external -FeaturePath "features/ai_trends.feature"

Write-Host "Results saved to allure-results and artifacts."
Write-Host "Run .\scripts\open-allure-report.ps1 to view the report."
