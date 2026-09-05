$ErrorActionPreference='Stop'
if (-not $env:CANDIDATE_PRIVATE_KEY) { throw 'Candidate decryption credential is missing.' }
$directory=Join-Path $PSScriptRoot 'out'
$meta=Get-Content -Raw (Join-Path $directory 'envelope.json') | ConvertFrom-Json
if ($meta.schemaVersion -ne 1 -or $meta.algorithm -ne 'AES-256-GCM+RSA-OAEP-SHA256') { throw 'Unsupported encrypted artifact.' }
$rsa=[Security.Cryptography.RSA]::Create()
try {
  $rsa.ImportFromPem($env:CANDIDATE_PRIVATE_KEY)
  $key=$rsa.Decrypt([Convert]::FromBase64String($meta.key),[Security.Cryptography.RSAEncryptionPadding]::OaepSHA256)
} finally { $rsa.Dispose() }
$cipher=[IO.File]::ReadAllBytes((Join-Path $directory 'candidate.enc'))
if ($cipher.Length -gt 30MB) { throw 'Encrypted candidate exceeds size limit.' }
$plain=[byte[]]::new($cipher.Length)
$aes=[Security.Cryptography.AesGcm]::new($key,16)
try { $aes.Decrypt([Convert]::FromBase64String($meta.nonce),$cipher,[Convert]::FromBase64String($meta.tag),$plain) }
finally { $aes.Dispose(); [Array]::Clear($key,0,$key.Length) }
$plainZip=Join-Path $directory 'candidate-private.zip'
[IO.File]::WriteAllBytes($plainZip,$plain)
Expand-Archive -LiteralPath $plainZip -DestinationPath (Join-Path $PSScriptRoot 'bundle/out') -Force
Remove-Item -LiteralPath $plainZip
Write-Host 'Candidate authenticity tag verified and artifact restored.'
