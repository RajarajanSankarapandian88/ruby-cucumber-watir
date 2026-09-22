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

function Test-GoogleSignedChromeDriver {
  param([string]$Path)

  if (-not (Test-Path -LiteralPath $Path)) { return $false }

  try {
    $Signature = Get-AuthenticodeSignature -FilePath $Path -ErrorAction Stop
    return $Signature.Status -eq "Valid" -and
      $Signature.SignerCertificate.Subject -match "Google LLC"
  }
  catch {
    return $false
  }
}

if ((Test-Path -LiteralPath $DriverPath) -and
    (Test-Path -LiteralPath $VersionFile) -and
    ((Get-Content -LiteralPath $VersionFile -Raw).Trim() -eq $ChromeVersion)) {
  if (Test-GoogleSignedChromeDriver -Path $DriverPath) {
    Write-Host "ChromeDriver already matches Chrome $ChromeVersion and has a valid Google signature"
    exit 0
  }

  Write-Warning "Cached ChromeDriver failed signature validation and will be replaced."
  Remove-Item -LiteralPath $DriverDirectory -Recurse -Force
  Remove-Item -LiteralPath $VersionFile -Force
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
$DriverUri = [Uri]$DriverDownload.url
if ($DriverUri.Scheme -ne "https" -or $DriverUri.Host -ne "storage.googleapis.com") {
  throw "ChromeDriver download URL is not the expected official HTTPS host."
}

New-Item -ItemType Directory -Path $ToolsDirectory -Force | Out-Null
$ArchivePath = Join-Path $ToolsDirectory "chromedriver-win64.zip"
try {
  Invoke-WebRequest -Uri $DriverDownload.url -OutFile $ArchivePath
  Expand-Archive -LiteralPath $ArchivePath -DestinationPath $ToolsDirectory -Force

  if (-not (Test-GoogleSignedChromeDriver -Path $DriverPath)) {
    throw "Downloaded ChromeDriver did not have a valid Google LLC code-signing signature."
  }
}
finally {
  if (Test-Path -LiteralPath $ArchivePath) {
    Remove-Item -LiteralPath $ArchivePath -Force
  }
}
Set-Content -LiteralPath $VersionFile -Value $ChromeVersion

Write-Host "Installed ChromeDriver $($VersionEntry.version) for Chrome $ChromeVersion"
