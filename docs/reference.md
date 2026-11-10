# cURL REST API reference

## Verified REST workflow

Send the owner key in the `ApiKey` header and in the method's `userKey` field where required. These examples call REST directly; the related gRPC contract is described separately below.

| Operation | GET route and query fields | Successful result | Handling |
|---|---|---|---|
| Start | `/Start`: flat account fields below | Object containing `copierId` | Reconcile after timeout before retrying |
| List | `/UserCopiers?userKey=...` | Array with paused state/reason | Empty array is valid; errors are not empty arrays |
| Pause/resume | `/CopierPause?id=...&paused=true` or `false` | `OK` text | Re-read state; billing can block resume |
| Remove | `/Remove?id=...&closeTrades=false` | `OK` text | Verify removal; positions are separate |
| Stored logs | `/TradeLogs?copierId=...&limit=20` | Event array | Match actual master and follower tickets |

The acceptance adapter normalizes replies to `ok` and `copier_id`; those fields are adapter output, not the REST response contract. Require a valid nonempty copier GUID after Start. Check HTTP status and business-error content: HTTP 201 can contain an error `code` and message. An empty object is never a successful Start.

## REST Start fields

REST requires nonempty account names and valid terminal GUIDs. The gRPC convenience layer can supply defaults; do not assume those defaults apply to REST.

| Query field | Meaning |
|---|---|
| `userKey`, `managerKey` | Owner and authorized manager; normally the same key |
| `masterType`, `slaveType` | Account routes, such as `MT5` on the tested deployment |
| `masterUser`, `slaveUser` | Broker login integers |
| `masterPassword`, `slavePassword` | Trading passwords |
| `masterServer`, `slaveServer` | Exact broker server names |
| `masterName`, `slaveName` | Required display labels, such as `Demo master` and `Demo follower` |
| `masterApiId`, `slaveApiId` | Required connected terminal GUIDs accepted by the copier API |
| `riskType`, `riskValue` | Sizing policy and decimal lots/multiplier |
| `fixedMasterBalance` | Positive denominator for FixedBalanceMultiplier; otherwise `0` |
| `copySL`, `copyTP` | Explicit booleans for protective levels |
| `copyPendingOrders`, `copyExistingTrades` | Use `false` for the introductory market-order test |

Encode values with `--data-urlencode`. The acceptance adapter passes its cURL configuration on standard input so secrets do not appear in process arguments. Keep private input files outside the checkout and avoid verbose request logging.

## Related gRPC request

The following fields describe the related proto for other SDKs. They are not interchangeable with the REST query fields above.

| Protocol field | Type | Meaning |
|---|---|---|
| `user_key` | string | Owner; defaults to configured identity |
| `manager_key` | string | Authorized creating manager; normally owner |
| `master`, `slave` | Account | Source and follower details |
| `risk_type` | string | One of five [sizing policies](sizing.md) |
| `risk_value` | decimal string | Lots or multiplier |
| `fixed_master_balance` | decimal string | Positive denominator for FixedBalanceMultiplier |
| `copy_sl`, `copy_tp` | bool | Copy protective levels |
| `copy_pending_orders` | bool | Include pending orders |
| `reverse_copy` | bool | Reverse direction |

Set booleans explicitly. Raw protobuf bools default to false; convenience defaults vary by wrapper.

## Account

| Field | Type | Meaning |
|---|---|---|
| `type` | string | `MT4` or `MT5` for the core model; use the deployment's supported account route |
| `user` | uint64 | Broker login, not API key |
| `password` | string | Broker password; secret |
| `server` | string | Exact broker server |
| `name` | string | Optional display label |
| `id` | string | Optional connected terminal/session ID |

Preserve 64-bit identifier precision. Node's underlying proto loader represents 64-bit response values as strings; do not round identifiers through floating-point conversions.

## Transport and version boundaries

Customer RPCs use `/copier.CopierService/Start`, `/List`, `/Pause`, `/Remove`. Default TLS target: `copy.mrpc.pro:443`. cURL examples use REST. C++ uses Windows WinHTTP, Java uses grpc-java; other SDKs use their language's gRPC library.

The checked-in [core proto](https://github.com/MetaRPC/CurlCopier/blob/main/proto/copier.proto) defines the related gRPC fields. Additional capabilities, including Update and operator billing calls, are outside the tested cURL workflow. See [authentication](authentication.md) for separately verified server behavior.

## Errors and resources

Handle transport failures and business-error objects. Close transports after use; closing a client does not stop a server-side copier. WebSocket events require the `ApiKey` header on `/OnTradeLog?id=<copier-id>`. Verify actual events and tickets, not just a successful connection. See [logs](logs.md) and [recovery](troubleshooting.md).
