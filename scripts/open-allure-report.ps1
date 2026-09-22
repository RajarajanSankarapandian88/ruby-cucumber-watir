[CmdletBinding()]
param(
  [switch]$GenerateOnly
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot
Set-Location -LiteralPath $ProjectRoot

if (-not (Test-Path -LiteralPath "allure-results")) {
  throw "No allure-results directory found. Run .\scripts\run-ai-trends.ps1 first."
}

& npx allure generate allure-results --output allure-report
if ($LASTEXITCODE -ne 0) { throw "Allure report generation failed with exit code $LASTEXITCODE" }

if (-not $GenerateOnly) {
  & npx allure open allure-report
}
