# Read-only. No accounts are created and no trades are placed.
$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($env:MRPC_API_KEY) -or $env:MRPC_API_KEY -eq 'TRIAL') { throw 'Set MRPC_API_KEY to your real MetaRPC owner API key.' }
$response = Invoke-RestMethod -Uri ('https://copy.mrpc.pro/UserCopiers?userKey=' + [Uri]::EscapeDataString($env:MRPC_API_KEY)) -Headers @{ ApiKey = $env:MRPC_API_KEY } -TimeoutSec 30
$response | ConvertTo-Json -Depth 15
