# MetaRPC CurlCopier

The official cURL guide and reference client for **MetaRPC Trade Copier** and **MetaTrader Terminal API**.

## Features
- **cURL HTTP/REST Integration**: Direct API access via standard `curl` commands.
- **Automated Demo Account Provisioning**: Wire-protocol demo account creation on demand.
- **Terminal Lifecycle Management**: `ConnectEx` with mandatory `APIKey: TRIAL` authentication and clean `/Disconnect` session termination.
- **Documentation**: Comprehensive MkDocs documentation site.

## 🏃 How to Run Examples

### 1. Clone Repo
```bash
git clone https://github.com/MetaRPC/CurlCopier.git
cd CurlCopier
```

### 2. Run with Default TRIAL Key
```bash
# On Linux / macOS (Bash):
bash examples/quickstart.sh

# On Windows (PowerShell):
powershell -ExecutionPolicy Bypass -File .\examples\quickstart.ps1

# Or on Windows using runner script:
.\run.bat
```

### 3. Run with Your Own API Key

Pass your API key directly as an argument:
```bash
# Windows
.\run.bat <YOUR_API_KEY>
# or PowerShell:
powershell -ExecutionPolicy Bypass -File .\examples\quickstart.ps1 <YOUR_API_KEY>

# Linux / macOS
bash examples/quickstart.sh <YOUR_API_KEY>
```

Or set the `MRPC_API_KEY` environment variable:
```bash
# Linux / macOS
export MRPC_API_KEY="<YOUR_API_KEY>"
bash examples/quickstart.sh

# Windows PowerShell
$env:MRPC_API_KEY="<YOUR_API_KEY>"
.\run.bat

# Windows CMD
set MRPC_API_KEY=<YOUR_API_KEY>
run.bat
```

---

## Protocol Examples

### 1. Provision Demo Account
```bash
curl -s -H "APIKey: TRIAL" "https://mt5.mrpc.pro/DemoAccount/Open?server=MetaQuotes-Demo"
```

### 2. Connect Terminal
```bash
curl -s -H "APIKey: TRIAL" "https://mt5.mrpc.pro/ConnectEx?user=123456&password=demoPass&mtClusterName=MetaQuotes-Demo"
```

### 3. Disconnect Terminal
```bash
# Gracefully stop terminal (delete=false by default)
curl -s -H "APIKey: TRIAL" -H "id: <terminalInstanceGuid>" "https://mt5.mrpc.pro/Disconnect"

# Permanently delete terminal session (delete=true for test teardown)
curl -s -H "APIKey: TRIAL" -H "id: <terminalInstanceGuid>" -H "delete: true" "https://mt5.mrpc.pro/Disconnect?delete=true"
```

## Documentation
Documentation is powered by MkDocs Material. Build with:
```bash
mkdocs build
```
