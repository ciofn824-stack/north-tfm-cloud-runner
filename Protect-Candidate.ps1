$ErrorActionPreference='Stop'
$directory=Join-Path $PSScriptRoot 'out'
New-Item -ItemType Directory -Force -Path $directory | Out-Null
$plainZip=Join-Path $directory 'candidate-private.zip'
$source=Join-Path $PSScriptRoot 'bundle/out'
Compress-Archive -LiteralPath @((Join-Path $source 'validated-candidate.swf'),(Join-Path $source 'validated-candidate.json'),(Join-Path $source 'cloud-update-report.json')) -DestinationPath $plainZip -Force
$plain=[IO.File]::ReadAllBytes($plainZip)
$key=[Security.Cryptography.RandomNumberGenerator]::GetBytes(32)
$nonce=[Security.Cryptography.RandomNumberGenerator]::GetBytes(12)
$tag=[byte[]]::new(16)
$cipher=[byte[]]::new($plain.Length)
$aes=[Security.Cryptography.AesGcm]::new($key,16)
try { $aes.Encrypt($nonce,$plain,$cipher,$tag) } finally { $aes.Dispose() }
$rsa=[Security.Cryptography.RSA]::Create()
try {
  $rsa.ImportFromPem((Get-Content -Raw (Join-Path $PSScriptRoot 'candidate-public.pem')))
  $wrapped=$rsa.Encrypt($key,[Security.Cryptography.RSAEncryptionPadding]::OaepSHA256)
} finally { $rsa.Dispose(); [Array]::Clear($key,0,$key.Length) }
[IO.File]::WriteAllBytes((Join-Path $directory 'candidate.enc'),$cipher)
@{schemaVersion=1;algorithm='AES-256-GCM+RSA-OAEP-SHA256';key=[Convert]::ToBase64String($wrapped);nonce=[Convert]::ToBase64String($nonce);tag=[Convert]::ToBase64String($tag)} | ConvertTo-Json | Set-Content (Join-Path $directory 'envelope.json')
# Only the encrypted .enc and envelope.json are selected for public artifacts.
Remove-Item -LiteralPath $plainZip
Write-Host 'Candidate encrypted for the isolated publication job.'
