---
hide:
  - toc
---
<div class="hero"><span class="eyebrow">METARPC / DEVELOPER GUIDES</span><h1>Trade copying.<br>Built with cURL.</h1><p>From your first authenticated request to a monitored master–follower workflow. Clear examples, explicit sizing and practical recovery.</p><a class="md-button md-button--primary" href="quickstart/">Start building →</a> <a class="md-button" href="reference/">Explore the API</a><div class="hero-meta">TLS transport · Owner authentication · Demo-first validation</div></div>

<div class="grid cards" markdown>

- **01 · Connect with confidence**

    Understand keys, account IDs and transport before sending a request.

    [Authentication →](authentication.md)

- **02 · Control the lifecycle**

    Start once, inspect state, pause and clean up your test.

    [Copier lifecycle →](lifecycle.md)

- **03 · Make sizing explicit**

    Choose lot, balance or equity sizing and account for broker constraints.

    [Sizing and settings →](sizing.md)

- **04 · Diagnose the result**

    Separate network success from management success and broker execution.

    [Troubleshooting →](troubleshooting.md)

</div>

## Your first successful request

Requires cURL 7.76+ and Bash, or PowerShell 5.1+. Install dependencies and run the read-only List example. Keep your key in `MRPC_API_KEY`.

```bash
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
```

[Full setup](quickstart.md) · [Testing guide](testing.md) · [All SDKs](sdks.md)
