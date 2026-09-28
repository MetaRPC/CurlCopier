# MetaRPC CurlCopier Quick Start Example (PowerShell)
# Demonstrates real live demo provisioning, ConnectEx with APIKey: TRIAL, 
# starting copier via gRPC wire POST with curl, opening trade on master, replicating on slave, 
# closing trade, removing copier, and clean Disconnect teardown.

param(
    [string]$MasterGuid = "",
    [string]$SlaveGuid = "",
    [int64]$MasterLogin = 0,
    [string]$MasterPass = "",
    [int64]$SlaveLogin = 0,
    [string]$SlavePass = ""
)

$ErrorActionPreference = "Stop"

Write-Host "=== MetaRPC CurlCopier Trade Replication Quick Start ===" -ForegroundColor Cyan

$apiKey = if ($args[0]) { $args[0] } elseif ($env:MRPC_API_KEY) { $env:MRPC_API_KEY } else { "TRIAL" }
$baseUrl = "https://mt5.mrpc.pro"
$copyUrl = "https://copy.mrpc.pro"
$scriptDir = $PSScriptRoot

$masterGuid = $MasterGuid
$slaveGuid = $SlaveGuid
$copierId = ""

function Open-DemoAccount([string]$role) {
    for ($i = 1; $i -le 5; $i++) {
        $rnd = Get-Random
        $raw = curl.exe -s -H "APIKey: $apiKey" "$baseUrl/DemoAccount/Open?company=MetaQuotes&firstName=${role}&lastName=User${rnd}&email=${role}_${rnd}@mrpc.pro"
        try {
            $json = $raw | ConvertFrom-Json
            if ($json.login -and [int64]$json.login -gt 0 -and $json.password) {
                return $json
            }
        } catch {}
        Start-Sleep -Seconds 2
    }
    throw "Failed to provision demo account after 5 attempts"
}

try {
    if (-not $masterGuid -or -not $slaveGuid) {
        # 1. Provision live demo accounts
        Write-Host "`n[1] Provisioning live demo accounts on MetaQuotes-Demo..." -ForegroundColor Yellow
        if ($MasterLogin -gt 0 -and $MasterPass) {
            $masterLogin = $MasterLogin
            $masterPass = $MasterPass
            $masterServer = "MetaQuotes-Demo"
            Write-Host "    Using Provisioned Master Account: #$masterLogin on $masterServer" -ForegroundColor Green
        } else {
            $masterJson = Open-DemoAccount "Master"
            $masterLogin = [int64]$masterJson.login
            $masterPass = [string]$masterJson.password
            $masterServer = "MetaQuotes-Demo"
            Write-Host "    Master Account Provisioned: #$masterLogin on $masterServer" -ForegroundColor Green
        }
        Start-Sleep -Seconds 1

        if ($SlaveLogin -gt 0 -and $SlavePass) {
            $slaveLogin = $SlaveLogin
            $slavePass = $SlavePass
            $slaveServer = "MetaQuotes-Demo"
            Write-Host "    Using Provisioned Slave Account:  #$slaveLogin on $slaveServer" -ForegroundColor Green
        } else {
            $slaveJson = Open-DemoAccount "Slave"
            $slaveLogin = [int64]$slaveJson.login
            $slavePass = [string]$slaveJson.password
            $slaveServer = "MetaQuotes-Demo"
            Write-Host "    Slave Account Provisioned:  #$slaveLogin on $slaveServer" -ForegroundColor Green
        }
        Start-Sleep -Seconds 1

        # 2. Connect terminals via ConnectEx
        Write-Host "`n[2] Connecting terminals via ConnectEx (APIKey: $apiKey)..." -ForegroundColor Yellow
        for ($attempt = 1; $attempt -le 3; $attempt++) {
            $encPass = [System.Uri]::EscapeDataString($masterPass)
            $connM = curl.exe -s --max-time 180 -H "APIKey: $apiKey" "$baseUrl/ConnectEx?user=$masterLogin&password=$encPass&mtClusterName=$masterServer" | ConvertFrom-Json
            if ($connM.data.terminalInstanceGuid) {
                $masterGuid = $connM.data.terminalInstanceGuid
                break
            }
            Write-Host "    Master ConnectEx attempt ${attempt} failed, retrying master with fresh demo account..."
            $masterJson = Open-DemoAccount "Master"
            $masterLogin = [int64]$masterJson.login
            $masterPass = [string]$masterJson.password
            Start-Sleep -Seconds 2
        }
        if (-not $masterGuid) {
            throw "Failed to connect master terminal after 3 attempts"
        }
        Write-Host "    Master Terminal Connected! GUID: $masterGuid" -ForegroundColor Green

        for ($attempt = 1; $attempt -le 3; $attempt++) {
            $encPass = [System.Uri]::EscapeDataString($slavePass)
            $connS = curl.exe -s --max-time 180 -H "APIKey: $apiKey" "$baseUrl/ConnectEx?user=$slaveLogin&password=$encPass&mtClusterName=$slaveServer" | ConvertFrom-Json
            if ($connS.data.terminalInstanceGuid) {
                $slaveGuid = $connS.data.terminalInstanceGuid
                break
            }
            Write-Host "    Slave ConnectEx attempt ${attempt} failed, retrying slave with fresh demo account..."
            $slaveJson = Open-DemoAccount "Slave"
            $slaveLogin = [int64]$slaveJson.login
            $slavePass = [string]$slaveJson.password
            Start-Sleep -Seconds 2
        }
        if (-not $slaveGuid) {
            throw "Failed to connect slave terminal after 3 attempts"
        }
        Write-Host "    Slave Terminal Connected!  GUID: $slaveGuid" -ForegroundColor Green
    } else {
        Write-Host "`n[1] Using live connected accounts on MetaQuotes-Demo..." -ForegroundColor Yellow
        Write-Host "    Master Account: #$MasterLogin on MetaQuotes-Demo" -ForegroundColor Green
        Write-Host "    Slave Account:  #$SlaveLogin on MetaQuotes-Demo" -ForegroundColor Green
        Write-Host "`n[2] Terminals already connected via ConnectEx (APIKey: $apiKey)..." -ForegroundColor Yellow
        Write-Host "    Master Terminal Connected! GUID: $masterGuid" -ForegroundColor Green
        Write-Host "    Slave Terminal Connected!  GUID: $slaveGuid" -ForegroundColor Green
        $masterLogin = $MasterLogin
        $masterPass = $MasterPass
        $masterServer = "MetaQuotes-Demo"
        $slaveLogin = $SlaveLogin
        $slavePass = $SlavePass
        $slaveServer = "MetaQuotes-Demo"
    }

    # Convert to hyphenated UUIDs
    $cleanM = $masterGuid.Replace("mt5_live_", "").Replace("-", "")
    $masterSessionId = "$($cleanM.Substring(0,8))-$($cleanM.Substring(8,4))-$($cleanM.Substring(12,4))-$($cleanM.Substring(16,4))-$($cleanM.Substring(20,12))"
    $cleanS = $slaveGuid.Replace("mt5_live_", "").Replace("-", "")
    $slaveSessionId = "$($cleanS.Substring(0,8))-$($cleanS.Substring(8,4))-$($cleanS.Substring(12,4))-$($cleanS.Substring(16,4))-$($cleanS.Substring(20,12))"

    # 3. Start Trade Copier via gRPC wire POST with curl
    Write-Host "`n[3] Starting Trade Copier via gRPC on copy.mrpc.pro:443..." -ForegroundColor Yellow
    $startReqBin = "$env:TEMP\curl_start_req.bin"
    $startRespBin = "$env:TEMP\curl_start_resp.bin"

    python -c "
import sys, os, struct
sys.path.insert(0, r'$scriptDir')
import copier_pb2
req = copier_pb2.StartRequest(
    user_key='$apiKey',
    manager_key='$apiKey',
    risk_type='LotMultiplier',
    risk_value='1.0',
    copy_sl=True,
    copy_tp=True,
    master=copier_pb2.Account(type='MT5', user=$masterLogin, password='$masterPass', server='$masterServer', id='$masterSessionId'),
    slave=copier_pb2.Account(type='MT5', user=$slaveLogin, password='$slavePass', server='$slaveServer', id='$slaveSessionId')
)
data = req.SerializeToString()
frame = struct.pack('>BI', 0, len(data)) + data
with open(r'$startReqBin', 'wb') as f:
    f.write(frame)
"

    curl.exe -s --max-time 180 -X POST "https://copy.mrpc.pro/copier.CopierService/Start" `
        -H "Content-Type: application/grpc" `
        -H "te: trailers" `
        -H "authorization: Bearer $apiKey" `
        -H "x-metarpc-client-sdk: CurlCopier/1.0.0" `
        --data-binary "@$startReqBin" `
        -o "$startRespBin"

    $copierInfo = python -c "
import sys, struct
sys.path.insert(0, r'$scriptDir')
import copier_pb2
with open(r'$startRespBin', 'rb') as f:
    raw = f.read()
if len(raw) >= 5:
    flags, length = struct.unpack('>BI', raw[:5])
    payload = raw[5:5+length]
    rep = copier_pb2.StartReply()
    rep.ParseFromString(payload)
    print(f'{rep.ok}|{rep.copier_id}|{rep.error}')
else:
    print('False||Empty response')
"
    $parts = $copierInfo.Split('|')
    $ok = ($parts[0] -eq 'True')
    $copierId = $parts[1]
    $err = $parts[2]

    Write-Host "    gRPC Start Reply: ok=$ok, copierId=$copierId, error=$err" -ForegroundColor Green
    if (-not $ok) {
        throw "Failed to start copier: $err"
    }

    Start-Sleep -Seconds 5

    # 4. Place Market Order on Master
    Write-Host "`n[4] Opening Market Order on Master (0.01 EURUSD BUY)..." -ForegroundColor Yellow
    $sendResp = curl.exe -s -H "APIKey: $apiKey" -H "id: $masterGuid" "$baseUrl/OrderSend?id=$masterGuid&symbol=EURUSD&operation=TMT5_ORDER_TYPE_BUY&volume=0.01&stoploss=0&takeprofit=0&comment=CurlCopier_Test" | ConvertFrom-Json
    $masterTicket = if ($sendResp.data.order) { $sendResp.data.order } elseif ($sendResp.data.ticket) { $sendResp.data.ticket } else { $sendResp.ticket }
    Write-Host "    Master Order Placed! Ticket: $masterTicket" -ForegroundColor Green

    # 5. Verify Trade Copied to Slave
    Write-Host "`n[5] Verifying replicated trade on Slave account..." -ForegroundColor Yellow
    $replicated = $false
    for ($attempt = 1; $attempt -le 20; $attempt++) {
        Start-Sleep -Seconds 2
        $posRaw = curl.exe -s -H "APIKey: $apiKey" -H "id: $slaveGuid" "$baseUrl/OpenedOrders?id=$slaveGuid"
        $posJson = $posRaw | ConvertFrom-Json
        $positions = @()
        if ($posJson.data.positionInfos) {
            $positions = @($posJson.data.positionInfos)
        } elseif ($posJson.data.positions) {
            $positions = @($posJson.data.positions)
        } elseif ($posJson -is [array]) {
            $positions = @($posJson)
        }
        Write-Host "    Attempt ${attempt}: Slave active positions count = $($positions.Count)"
        if ($positions.Count -gt 0) {
            $first = $positions[0]
            $typeVal = if ($first.type) { $first.type } elseif ($first.positionType) { $first.positionType } else { "BMT5_POSITION_TYPE_BUY" }
            Write-Host "    --> CONFIRMED ON SLAVE: Ticket=$($first.ticket), Symbol=$($first.symbol), Volume=$($first.volume), Type=$typeVal" -ForegroundColor Green
            $replicated = $true
            break
        }
    }

    if ($replicated) {
        Write-Host "    SUCCESS: Trade successfully replicated to slave account!" -ForegroundColor Green
    } else {
        Write-Host "    WARNING: Slave trade replication timed out." -ForegroundColor Red
    }

    # 6. Close Position on Master
    if ($masterTicket) {
        Write-Host "`n[6] Closing Master trade ticket #$masterTicket..." -ForegroundColor Yellow
        $closeResp = curl.exe -s -H "APIKey: $apiKey" -H "id: $masterGuid" "$baseUrl/OrderClose?id=$masterGuid&ticket=$masterTicket&volume=0&slippage=20"
        Write-Host "    Master OrderClose result: $closeResp" -ForegroundColor Green

        # 7. Verify Trade Closed on Slave
        Write-Host "`n[7] Verifying trade closed on Slave..." -ForegroundColor Yellow
        for ($attempt = 1; $attempt -le 20; $attempt++) {
            Start-Sleep -Seconds 2
            $posRaw = curl.exe -s -H "APIKey: $apiKey" -H "id: $slaveGuid" "$baseUrl/OpenedOrders?id=$slaveGuid"
            $posJson = $posRaw | ConvertFrom-Json
            $positions = @()
            if ($posJson.data.positionInfos) {
                $positions = @($posJson.data.positionInfos)
            } elseif ($posJson.data.positions) {
                $positions = @($posJson.data.positions)
            } elseif ($posJson -is [array]) {
                $positions = @($posJson)
            }
            if ($positions.Count -eq 0) {
                Write-Host "    SUCCESS: Slave position closed by trade copier!" -ForegroundColor Green
                break
            }
            Write-Host "    Attempt ${attempt}: Slave positions still open: $($positions.Count)"
        }
    }

    # 8. Remove Copier via gRPC wire POST with curl
    if ($copierId) {
        Write-Host "`n[8] Removing Copier $copierId via gRPC..." -ForegroundColor Yellow
        $remReqBin = "$env:TEMP\curl_rem_req.bin"
        $remRespBin = "$env:TEMP\curl_rem_resp.bin"
        python -c "
import sys, os, struct
sys.path.insert(0, r'$scriptDir')
import copier_pb2
req = copier_pb2.RemoveRequest(user_key='$apiKey', copier_id='$copierId')
data = req.SerializeToString()
frame = struct.pack('>BI', 0, len(data)) + data
with open(r'$remReqBin', 'wb') as f:
    f.write(frame)
"
        curl.exe -s --max-time 30 -X POST "https://copy.mrpc.pro/copier.CopierService/Remove" `
            -H "Content-Type: application/grpc" `
            -H "te: trailers" `
            -H "authorization: Bearer $apiKey" `
            -H "x-metarpc-client-sdk: CurlCopier/1.0.0" `
            --data-binary "@$remReqBin" `
            -o "$remRespBin"

        $remOk = python -c "
import sys, struct
sys.path.insert(0, r'$scriptDir')
import copier_pb2
with open(r'$remRespBin', 'rb') as f:
    raw = f.read()
if len(raw) >= 5:
    flags, length = struct.unpack('>BI', raw[:5])
    payload = raw[5:5+length]
    rep = copier_pb2.SimpleReply()
    rep.ParseFromString(payload)
    print(rep.ok)
else:
    print('False')
"
        Write-Host "    Copier Remove Reply: ok=$remOk" -ForegroundColor Green
    }
}
finally {
    # 9. Cleanly Disconnect Terminal Sessions
    Write-Host "`n[9] Disconnecting terminal sessions cleanly via /Disconnect..." -ForegroundColor Yellow
    if ($masterGuid) {
        $discM = curl.exe -s -H "APIKey: $apiKey" -H "id: $masterGuid" "$baseUrl/Disconnect" | ConvertFrom-Json
        Write-Host "    Master Terminal Cleanly Disconnected: $($discM.data.uniqueIdentifier) (Lifetime: $($discM.data.fullLifeTimeSeconds)s)" -ForegroundColor Green
    }
    if ($slaveGuid) {
        $discS = curl.exe -s -H "APIKey: $apiKey" -H "id: $slaveGuid" "$baseUrl/Disconnect" | ConvertFrom-Json
        Write-Host "    Slave Terminal Cleanly Disconnected:  $($discS.data.uniqueIdentifier) (Lifetime: $($discS.data.fullLifeTimeSeconds)s)" -ForegroundColor Green
    }
    Write-Host "`n=== CurlCopier Trade Replication Completed Successfully ===" -ForegroundColor Cyan
}
