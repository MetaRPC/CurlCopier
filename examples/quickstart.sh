#!/usr/bin/env bash
set -euo pipefail
: "${MRPC_API_KEY:?Set MRPC_API_KEY to your real MetaRPC owner API key}"
case "${MRPC_API_KEY}" in
  [Tt][Rr][Ii][Aa][Ll]) echo "TRIAL is not a copier owner key" >&2; exit 1 ;;
esac
# Read-only. No accounts are created and no trades are placed.
curl --fail-with-body --silent --show-error --max-time 30 \
  -H "ApiKey: ${MRPC_API_KEY}" \
  --get --data-urlencode "userKey=${MRPC_API_KEY}" \
  "https://copy.mrpc.pro/UserCopiers"
