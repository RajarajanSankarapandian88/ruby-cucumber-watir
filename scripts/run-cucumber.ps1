[CmdletBinding()]
param(
  [ValidateSet("allure", "external")]
  [string]$Profile = "allure",
  [string[]]$FeaturePath = @("features")
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$AllureResults = Join-Path $ProjectRoot "allure-results"
$env:Path = "C:\Ruby40-x64\bin;$env:Path"

Set-Location -LiteralPath $ProjectRoot

# This is the sole cleanup point for Allure report runs. Cucumber processes
# append results, allowing a future parallel runner to share this directory.
if (Test-Path -LiteralPath $AllureResults) {
  Remove-Item -LiteralPath $AllureResults -Recurse -Force
}
New-Item -ItemType Directory -Path $AllureResults -Force | Out-Null

& bundle exec cucumber --profile $Profile @FeaturePath
if ($LASTEXITCODE -ne 0) {
  throw "Cucumber failed with exit code $LASTEXITCODE"
}
