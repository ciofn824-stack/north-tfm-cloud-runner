$ErrorActionPreference='Stop'
$config=Get-Content -Raw (Join-Path $PSScriptRoot 'runner-config.json') | ConvertFrom-Json
if (-not $env:TOOLS_READ_SECRET) { throw 'Private tool download credential is missing.' }
$zip=Join-Path $PSScriptRoot 'toolchain.zip'
Invoke-WebRequest -Uri $config.toolsUrl -Headers @{Authorization=('Bearer '+$env:TOOLS_READ_SECRET)} -OutFile $zip -TimeoutSec 90
$hash=(Get-FileHash -Algorithm SHA256 -LiteralPath $zip).Hash.ToLowerInvariant()
if ($hash -ne $config.toolsSha256) { throw 'Private toolchain hash mismatch.' }
Expand-Archive -LiteralPath $zip -DestinationPath (Join-Path $PSScriptRoot 'bundle') -Force
Write-Host 'Pinned private toolchain downloaded and verified.'
