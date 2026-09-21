# MetaRPC CurlCopier

The official cURL guide and reference client for **MetaRPC Trade Copier** and **MetaTrader Terminal API**.

## Features
- **cURL HTTP/REST Integration**: Direct API access via standard `curl` commands.
- **Automated Demo Account Provisioning**: Wire-protocol demo account creation on demand.
- **Terminal Lifecycle Management**: `ConnectEx` with mandatory `APIKey: TRIAL` authentication and clean `/Disconnect` session termination.
- **Documentation**: Comprehensive MkDocs documentation site.

## Quick Start

### PowerShell
```powershell
.\examples\quickstart.ps1
```

### Bash
```bash
bash examples/quickstart.sh
```

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
curl -s -H "APIKey: TRIAL" -H "id: <terminalInstanceGuid>" "https://mt5.mrpc.pro/Disconnect"
```

## Documentation
Documentation is powered by MkDocs Material. Build with:
```bash
mkdocs build
```
