#!/usr/bin/env bash
set -e

# MetaRPC CurlCopier Quick Start Example (Bash)
# Demonstrates real live demo provisioning, ConnectEx with APIKey: TRIAL, and clean Disconnect teardown.

echo "=== MetaRPC CurlCopier Quick Start Demo ==="

API_KEY="TRIAL"
BASE_URL="https://mt5.mrpc.pro"
COPY_URL="https://copy.mrpc.pro"

# 1. Provision a real demo account via wire protocol
echo ""
echo "[1] Provisioning demo MetaTrader 5 account via DemoAccount/Open..."
OPEN_RESP=$(curl -s -H "APIKey: ${API_KEY}" "${BASE_URL}/DemoAccount/Open?server=MetaQuotes-Demo")
LOGIN=$(echo "${OPEN_RESP}" | grep -o '"login":"[^"]*' | cut -d'"' -f4)
PASS=$(echo "${OPEN_RESP}" | grep -o '"password":"[^"]*' | cut -d'"' -f4)
SERVER=$(echo "${OPEN_RESP}" | grep -o '"server":"[^"]*' | cut -d'"' -f4)
echo "    Provisioned Account: #${LOGIN} (${SERVER})"

# 2. Connect MT5 terminal instance via ConnectEx
echo ""
echo "[2] Connecting MT5 terminal instance via ConnectEx (APIKey: ${API_KEY})..."
ENCODED_PASS=$(python3 -c "import urllib.parse, sys; print(urllib.parse.quote(sys.argv[1]))" "${PASS}" 2>/dev/null || node -e "console.log(encodeURIComponent(process.argv[1]))" "${PASS}")
CONN_RESP=$(curl -s -H "APIKey: ${API_KEY}" "${BASE_URL}/ConnectEx?user=${LOGIN}&password=${ENCODED_PASS}&mtClusterName=${SERVER}")
TERM_ID=$(echo "${CONN_RESP}" | grep -o '"terminalInstanceGuid":"[^"]*' | cut -d'"' -f4)
echo "    Terminal Connected! ID: ${TERM_ID}"

# 3. Check Trade Copier Gateway Health
echo ""
echo "[3] Checking MetaRPC Trade Copier Gateway..."
HEALTH=$(curl -s "${COPY_URL}/healthz")
echo "    Copier Gateway Status: ${HEALTH}"

# 4. Cleanly Disconnect Terminal Session
echo ""
echo "[4] Disconnecting terminal session to ensure clean teardown..."
DISC_RESP=$(curl -s -H "APIKey: ${API_KEY}" -H "id: ${TERM_ID}" "${BASE_URL}/Disconnect")
DISC_ID=$(echo "${DISC_RESP}" | grep -o '"uniqueIdentifier":"[^"]*' | cut -d'"' -f4)
LIFETIME=$(echo "${DISC_RESP}" | grep -o '"fullLifeTimeSeconds":[0-9]*' | cut -d':' -f2)
echo "    Terminal Cleanly Disconnected: ${DISC_ID} (Lifetime: ${LIFETIME}s)"

echo ""
echo "=== CurlCopier Quick Start Completed Successfully ==="
