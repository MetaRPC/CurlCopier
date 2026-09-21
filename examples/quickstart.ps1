# MetaRPC CurlCopier Quick Start Example (PowerShell)
# Demonstrates real live demo provisioning, ConnectEx with APIKey: TRIAL, and clean Disconnect teardown.

Write-Host "=== MetaRPC CurlCopier Quick Start Demo ===" -ForegroundColor Cyan

$apiKey = "TRIAL"
$baseUrl = "https://mt5.mrpc.pro"
$copyUrl = "https://copy.mrpc.pro"

# 1. Provision a real demo account via wire protocol
Write-Host "`n[1] Provisioning demo MetaTrader 5 account via DemoAccount/Open..." -ForegroundColor Yellow
$openResp = curl.exe -s -H "APIKey: $apiKey" "$baseUrl/DemoAccount/Open?server=MetaQuotes-Demo" | ConvertFrom-Json
$login = $openResp.login
$password = $openResp.password
$server = $openResp.server
Write-Host "    Provisioned Account: #$login ($server)" -ForegroundColor Green

# 2. Connect MT5 terminal instance via ConnectEx
Write-Host "`n[2] Connecting MT5 terminal instance via ConnectEx (APIKey: $apiKey)..." -ForegroundColor Yellow
$encodedPass = [System.Uri]::EscapeDataString($password)
$connResp = curl.exe -s -H "APIKey: $apiKey" "$baseUrl/ConnectEx?user=$login&password=$encodedPass&mtClusterName=$server" | ConvertFrom-Json
$termId = $connResp.data.terminalInstanceGuid
Write-Host "    Terminal Connected! ID: $termId" -ForegroundColor Green

# 3. Check Trade Copier Gateway Health
Write-Host "`n[3] Checking MetaRPC Trade Copier Gateway..." -ForegroundColor Yellow
$health = curl.exe -s "$copyUrl/healthz"
Write-Host "    Copier Gateway Status: $health" -ForegroundColor Green

# 4. Cleanly Disconnect Terminal Session
Write-Host "`n[4] Disconnecting terminal session to ensure clean teardown..." -ForegroundColor Yellow
$discResp = curl.exe -s -H "APIKey: $apiKey" -H "id: $termId" "$baseUrl/Disconnect" | ConvertFrom-Json
$discId = $discResp.data.uniqueIdentifier
$lifetime = $discResp.data.fullLifeTimeSeconds
Write-Host "    Terminal Cleanly Disconnected: $discId (Lifetime: ${lifetime}s)" -ForegroundColor Green

Write-Host "`n=== CurlCopier Quick Start Completed Successfully ===" -ForegroundColor Cyan
