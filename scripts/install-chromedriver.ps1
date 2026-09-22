[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$ChromeCandidates = @(
  "C:\Program Files\Google\Chrome\Application\chrome.exe",
  "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
)
$ChromePath = $ChromeCandidates | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
if (-not $ChromePath) { throw "Google Chrome is not installed." }

$ChromeVersion = (Get-Item -LiteralPath $ChromePath).VersionInfo.ProductVersion
$ToolsDirectory = Join-Path $ProjectRoot "tools"
$DriverDirectory = Join-Path $ToolsDirectory "chromedriver-win64"
$DriverPath = Join-Path $DriverDirectory "chromedriver.exe"
$VersionFile = Join-Path $ToolsDirectory "chrome-version.txt"

if ((Test-Path -LiteralPath $DriverPath) -and
    (Test-Path -LiteralPath $VersionFile) -and
    ((Get-Content -LiteralPath $VersionFile -Raw).Trim() -eq $ChromeVersion)) {
  Write-Host "ChromeDriver already matches Chrome $ChromeVersion"
  exit 0
}

$MetadataUrl = "https://googlechromelabs.github.io/chrome-for-testing/known-good-versions-with-downloads.json"
$Metadata = Invoke-RestMethod -Uri $MetadataUrl
$VersionEntry = $Metadata.versions | Where-Object { $_.version -eq $ChromeVersion } | Select-Object -First 1
if (-not $VersionEntry) {
  $ChromeBuild = ($ChromeVersion -split "\.")[0..2] -join "."
  $VersionEntry = $Metadata.versions |
    Where-Object { $_.version -like "$ChromeBuild.*" -and $_.downloads.chromedriver } |
    Sort-Object { [version]$_.version } -Descending |
    Select-Object -First 1
}
if (-not $VersionEntry) { throw "No compatible official ChromeDriver found for Chrome $ChromeVersion." }

$DriverDownload = $VersionEntry.downloads.chromedriver |
  Where-Object { $_.platform -eq "win64" } |
  Select-Object -First 1
if (-not $DriverDownload) { throw "No Windows x64 ChromeDriver found for Chrome $ChromeVersion." }

New-Item -ItemType Directory -Path $ToolsDirectory -Force | Out-Null
$ArchivePath = Join-Path $ToolsDirectory "chromedriver-win64.zip"
Invoke-WebRequest -Uri $DriverDownload.url -OutFile $ArchivePath
Expand-Archive -LiteralPath $ArchivePath -DestinationPath $ToolsDirectory -Force
Remove-Item -LiteralPath $ArchivePath
Set-Content -LiteralPath $VersionFile -Value $ChromeVersion

Write-Host "Installed ChromeDriver $($VersionEntry.version) for Chrome $ChromeVersion"
