# A copier from start to shutdown

A copier is a persistent relationship between a **master** (source) and **slave** (follower). Management success and broker execution must be checked independently.

## 1. Prepare two demo accounts

Use two different disposable demo accounts. Confirm exact server names and the follower's trading password. Check instrument market hours, minimum lot, lot step, available margin and symbol suffix on both brokers. A displayed quote does not prove trading is open.

This repository does not provide a terminal-provisioning library. Connect the demo accounts through the separate MT4/MT5 terminal service and retain their terminal GUIDs. Terminal credentials do not replace copier authentication; send the real owner key in `ApiKey`.

## 2. Start once, then inspect

Send the flat REST `/Start` fields listed in the [API reference](reference.md), including required master/follower names and terminal GUIDs. Choose sizing deliberately and set booleans explicitly. Check HTTP status and business-error content, then require a valid `copierId`. The test adapter's `ok` and `copier_id` fields are its normalized output.

A timeout does not prove Start failed. Call List and reconcile the master/follower pair before starting again. Blind retries can create duplicate replication.

## 3. Verify real replication

1. Confirm the copier appears in List and is not paused.
2. Open one small demo position on the master after explicitly enabling the test.
3. Wait with a deadline for the follower position and matching trade log.
4. Compare symbol, direction, lot size and both tickets.
5. Close the master position and verify the expected follower close.
6. Record broker refusals and logs. A copier ID alone does not prove a successful trade.

## 4. Pause and resume

Pause changes copier processing. It does **not** close broker positions. Read List after either operation and inspect `paused` and `pause_reason`. Billing suspension can refuse a customer resume; resolve its cause instead of retrying indefinitely.

## 5. Remove and clean up

Remove deletes the copier relationship; it does not replace position management. Confirm positions and pending orders on both accounts before removal. Close only this run's test positions, remove its copier, and disconnect only terminal sessions it created.

Ending a cURL process or closing a WebSocket does **not** remove a server-side copier.

## IDs you must not mix up

| Value | Purpose |
|---|---|
| Owner/API key | Authentication; secret |
| Broker login | Trading-account number |
| Broker server | Exact server name |
| Terminal/session ID | Connected terminal instance |
| Copier ID | Relationship returned by Start |
| Ticket | Broker order/position ID; differs between accounts |
