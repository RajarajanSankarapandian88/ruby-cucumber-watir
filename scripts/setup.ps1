[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$RubyBin = "C:\Ruby40-x64\bin"

if (-not (Test-Path -LiteralPath "$RubyBin\ruby.exe")) {
  throw "Ruby 4.0 was not found at $RubyBin. Install Ruby 4.0.7 before running setup."
}

$env:Path = "$RubyBin;$env:Path"
Set-Location -LiteralPath $ProjectRoot

Write-Host "Using $(& ruby --version)"

# RubyInstaller uses OpenSSL's CA bundle rather than the Windows certificate
# store. Export trusted Windows roots so Bundler also works behind a corporate
# TLS inspection proxy while retaining full certificate verification.
$CertificateDirectory = Join-Path $ProjectRoot ".certs"
$CertificateBundle = Join-Path $CertificateDirectory "windows-roots.pem"
New-Item -ItemType Directory -Path $CertificateDirectory -Force | Out-Null
$TrustedRoots = Get-ChildItem Cert:\CurrentUser\Root, Cert:\LocalMachine\Root |
  Sort-Object Thumbprint -Unique
$PemBlocks = foreach ($Certificate in $TrustedRoots) {
  "-----BEGIN CERTIFICATE-----"
  [Convert]::ToBase64String($Certificate.RawData, [Base64FormattingOptions]::InsertLineBreaks)
  "-----END CERTIFICATE-----"
}
[IO.File]::WriteAllLines($CertificateBundle, $PemBlocks)
$env:SSL_CERT_FILE = $CertificateBundle

& "$RubyBin\ridk.cmd" enable
& bundle config set --local path "vendor/bundle"
& bundle config set --local force_ruby_platform true
& bundle install
if ($LASTEXITCODE -ne 0) { throw "bundle install failed with exit code $LASTEXITCODE" }

& npm ci --include=dev
if ($LASTEXITCODE -ne 0) { throw "npm ci failed with exit code $LASTEXITCODE" }

& "$PSScriptRoot\install-chromedriver.ps1"

Write-Host "Setup complete. Run .\scripts\run-ai-trends.ps1"
