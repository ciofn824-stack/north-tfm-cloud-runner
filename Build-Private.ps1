$ErrorActionPreference='Stop'
try {
  & ./bundle/scripts/Invoke-NorthTFMCloudUpdate.ps1 *> ./bundle/build-private.log
  & python ./bundle/scripts/Test-ValidatorSafety.py ./bundle/out/validated-candidate.swf *> ./bundle/validation-private.log
  if ($LASTEXITCODE -ne 0) { throw 'Validation failed.' }
} catch {
  # Generator diagnostics can contain private implementation data.
  # Keep them inside the ephemeral runner, never in this public run's logs.
  throw 'Private build or validation failed; nothing has been published.'
}
Write-Host 'Independent build, schema and corruption tests passed.'
