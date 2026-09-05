$ErrorActionPreference='Stop'
$base=Join-Path $PSScriptRoot 'bundle/out'
$manifest=Get-Content -Raw (Join-Path $base 'validated-candidate.json') | ConvertFrom-Json
$candidate=Join-Path $base 'validated-candidate.swf'
$hash=(Get-FileHash -Algorithm SHA256 -LiteralPath $candidate).Hash.ToLowerInvariant()
if ($hash -ne $manifest.candidate.sha256 -or (Get-Item -LiteralPath $candidate).Length -ne $manifest.candidate.bytes) {
  throw 'Decrypted artifact does not match its validated manifest.'
}
Write-Host 'Encrypted transfer restored the exact validated candidate.'
