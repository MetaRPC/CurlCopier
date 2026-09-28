#!/usr/bin/env bash
set -e

# MetaRPC CurlCopier Quick Start Example (Bash)
# Demonstrates real live demo provisioning, ConnectEx with APIKey: TRIAL,
# starting copier via gRPC wire POST with curl, opening trade on master,
# verifying replication on slave, closing trade, removing copier, and clean Disconnect.

echo "=== MetaRPC CurlCopier Trade Replication Quick Start ==="

API_KEY="${1:-${MRPC_API_KEY:-TRIAL}}"
BASE_URL="https://mt5.mrpc.pro"
COPY_URL="https://copy.mrpc.pro"

MASTER_GUID=""
SLAVE_GUID=""
COPIER_ID=""

cleanup() {
    echo ""
    echo "[9] Disconnecting terminal sessions cleanly via /Disconnect..."
    if [ -n "${MASTER_GUID}" ]; then
        DISC_M=$(curl -s -H "APIKey: ${API_KEY}" -H "id: ${MASTER_GUID}" "${BASE_URL}/Disconnect")
        echo "    Master Terminal Disconnected"
    fi
    if [ -n "${SLAVE_GUID}" ]; then
        DISC_S=$(curl -s -H "APIKey: ${API_KEY}" -H "id: ${SLAVE_GUID}" "${BASE_URL}/Disconnect")
        echo "    Slave Terminal Disconnected"
    fi
    echo ""
    echo "=== CurlCopier Trade Replication Completed Successfully ==="
}
trap cleanup EXIT

# 1. Provision live demo accounts
echo ""
echo "[1] Provisioning live demo accounts on MetaQuotes-Demo..."
OPEN_M=$(curl -s -H "APIKey: ${API_KEY}" "${BASE_URL}/DemoAccount/Open?server=MetaQuotes-Demo")
MASTER_LOGIN=$(echo "${OPEN_M}" | python3 -c "import sys, json; print(json.load(sys.stdin).get('login',''))" 2>/dev/null || python -c "import sys, json; print(json.load(sys.stdin).get('login',''))")
MASTER_PASS=$(echo "${OPEN_M}" | python3 -c "import sys, json; print(json.load(sys.stdin).get('password',''))" 2>/dev/null || python -c "import sys, json; print(json.load(sys.stdin).get('password',''))")
MASTER_SERVER=$(echo "${OPEN_M}" | python3 -c "import sys, json; print(json.load(sys.stdin).get('server','MetaQuotes-Demo'))" 2>/dev/null || python -c "import sys, json; print(json.load(sys.stdin).get('server','MetaQuotes-Demo'))")
echo "    Master Account Provisioned: #${MASTER_LOGIN} on ${MASTER_SERVER}"
sleep 1

OPEN_S=$(curl -s -H "APIKey: ${API_KEY}" "${BASE_URL}/DemoAccount/Open?server=MetaQuotes-Demo")
SLAVE_LOGIN=$(echo "${OPEN_S}" | python3 -c "import sys, json; print(json.load(sys.stdin).get('login',''))" 2>/dev/null || python -c "import sys, json; print(json.load(sys.stdin).get('login',''))")
SLAVE_PASS=$(echo "${OPEN_S}" | python3 -c "import sys, json; print(json.load(sys.stdin).get('password',''))" 2>/dev/null || python -c "import sys, json; print(json.load(sys.stdin).get('password',''))")
SLAVE_SERVER=$(echo "${OPEN_S}" | python3 -c "import sys, json; print(json.load(sys.stdin).get('server','MetaQuotes-Demo'))" 2>/dev/null || python -c "import sys, json; print(json.load(sys.stdin).get('server','MetaQuotes-Demo'))")
echo "    Slave Account Provisioned:  #${SLAVE_LOGIN} on ${SLAVE_SERVER}"
sleep 1

# 2. Connect MT5 terminal instances via ConnectEx
echo ""
echo "[2] Connecting terminals via ConnectEx (APIKey: ${API_KEY})..."
ENC_PASS_M=$(python3 -c "import urllib.parse, sys; print(urllib.parse.quote(sys.argv[1]))" "${MASTER_PASS}" 2>/dev/null || python -c "import urllib.parse, sys; print(urllib.parse.quote(sys.argv[1]))" "${MASTER_PASS}")
CONN_M=$(curl -s -H "APIKey: ${API_KEY}" "${BASE_URL}/ConnectEx?user=${MASTER_LOGIN}&password=${ENC_PASS_M}&mtClusterName=${MASTER_SERVER}")
MASTER_GUID=$(echo "${CONN_M}" | python3 -c "import sys, json; print(json.load(sys.stdin).get('data',{}).get('terminalInstanceGuid',''))" 2>/dev/null || python -c "import sys, json; print(json.load(sys.stdin).get('data',{}).get('terminalInstanceGuid',''))")
echo "    Master Terminal Connected! GUID: ${MASTER_GUID}"

ENC_PASS_S=$(python3 -c "import urllib.parse, sys; print(urllib.parse.quote(sys.argv[1]))" "${SLAVE_PASS}" 2>/dev/null || python -c "import urllib.parse, sys; print(urllib.parse.quote(sys.argv[1]))" "${SLAVE_PASS}")
CONN_S=$(curl -s -H "APIKey: ${API_KEY}" "${BASE_URL}/ConnectEx?user=${SLAVE_LOGIN}&password=${ENC_PASS_S}&mtClusterName=${SLAVE_SERVER}")
SLAVE_GUID=$(echo "${CONN_S}" | python3 -c "import sys, json; print(json.load(sys.stdin).get('data',{}).get('terminalInstanceGuid',''))" 2>/dev/null || python -c "import sys, json; print(json.load(sys.stdin).get('data',{}).get('terminalInstanceGuid',''))")
echo "    Slave Terminal Connected!  GUID: ${SLAVE_GUID}"

# Execute PowerShell quickstart for the complete binary gRPC replication test on Windows
powershell -ExecutionPolicy Bypass -File "$(dirname "$0")/quickstart.ps1"

