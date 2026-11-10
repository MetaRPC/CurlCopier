# MetaRPC cURL Trade Copier SDK

Authenticate, configure a master–follower relationship, inspect its state, pause and remove it.

**[Documentation](https://metarpc.github.io/CurlCopier/) · [Quickstart](https://metarpc.github.io/CurlCopier/quickstart/) · [Authentication](https://metarpc.github.io/CurlCopier/authentication/) · [API reference](https://metarpc.github.io/CurlCopier/reference/)**

## Install from source

Requires cURL 7.76+ and Bash, or PowerShell 5.1+.

```bash
git clone https://github.com/MetaRPC/CurlCopier.git
cd CurlCopier
curl --version
```

## First request

Set `MRPC_API_KEY` to your real owner API key in your environment, then run:

```bash
bash examples/quickstart.sh
```

This List example is read-only: no account creation or trades. Java on Windows uses `;` instead of `:` in classpaths.

## Authentication

Every SDK call sends `ApiKey` (`apikey` in gRPC metadata). The gRPC body also carries `user_key`; the header does not replace it. `TRIAL` is not an owner key. Read the [verified transport contract](https://metarpc.github.io/CurlCopier/authentication/).

## Scope and verification

Core operations: REST routes; no language wrapper. Advanced server features are distinguished from the supported wrapper surface. Review legacy replication examples before using them with disposable demos. Standard tests need no broker credentials.

See [testing and contributing](https://metarpc.github.io/CurlCopier/testing/) for the regression suite, demo checklist and Pages build. Edit `docs/`; generated `site/` output is not source.
