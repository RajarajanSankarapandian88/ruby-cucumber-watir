[CmdletBinding()]
param(
  [switch]$GenerateOnly
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot
Set-Location -LiteralPath $ProjectRoot
$AllureCli = Join-Path $ProjectRoot "node_modules\.bin\allure.cmd"

if (-not (Test-Path -LiteralPath "allure-results")) {
  throw "No allure-results directory found. Run .\scripts\run-ai-trends.ps1 first."
}
if (-not (Test-Path -LiteralPath $AllureCli)) {
  throw "Allure CLI is not installed. Run .\scripts\setup.ps1 first."
}

& $AllureCli generate allure-results --output allure-report
if ($LASTEXITCODE -ne 0) { throw "Allure report generation failed with exit code $LASTEXITCODE" }

if (-not $GenerateOnly) {
  & $AllureCli open allure-report
}
