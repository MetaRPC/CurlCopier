# First request with cURL

List your own copiers to check connectivity and identity without creating a terminal or placing a trade.

## 1. Install

Requires **cURL 7.76+ and Bash, or PowerShell 5.1+**. These instructions build from source; they do not assume a registry release exists.

```bash
git clone https://github.com/MetaRPC/CurlCopier.git
cd CurlCopier
curl --version
```

Java on Windows uses `;` for classpath separators. Run C++ builds in a Visual Studio developer shell. Activate your Python virtual environment before installing.

## 2. Set your owner key

=== "Bash"
    ```bash
    export MRPC_API_KEY='your-owner-key'
    ```
=== "PowerShell"
    ```powershell
    $env:MRPC_API_KEY = 'your-owner-key'
    ```

Use the real owner API key, not a broker password, terminal ID or `TRIAL`. Read [authentication](authentication.md) if access is refused.

## 3. Run

```bash
bash examples/quickstart.sh
```

Source: [`examples/quickstart.sh`](https://github.com/MetaRPC/CurlCopier/blob/main/examples/quickstart.sh).

```bash
#!/usr/bin/env bash
set -euo pipefail
: "${MRPC_API_KEY:?Set MRPC_API_KEY to your real MetaRPC owner API key}"
[[ "${MRPC_API_KEY^^}" != TRIAL ]] || { echo "TRIAL is not a copier owner key" >&2; exit 1; }
# Read-only. No accounts are created and no trades are placed.
curl --fail-with-body --silent --show-error --max-time 30 \
  -H "ApiKey: ${MRPC_API_KEY}" \
  --get --data-urlencode "userKey=${MRPC_API_KEY}" \
  "https://copy.mrpc.pro/UserCopiers"
```

A successful empty list means this owner has no copiers. Treat failed requests as errors, not empty accounts.

## 4. Prepare a demo workflow

Read [the lifecycle guide](lifecycle.md), then [choose sizing](sizing.md). Existing replication examples under `examples/` are advanced integration examples: they may provision accounts and trade. Inspect them and their cleanup before running with disposable demos. List is the default starting point.
