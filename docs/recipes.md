# Lifecycle recipes

This recipe pauses an existing copier using REST. The REST Start route accepts broker passwords in its query string; prefer one of the gRPC SDKs for creating a copier without putting passwords in URLs. Do not invent a POST body for this GET-only route.

```bash
# Manage an existing copier you own. Keep its ID from a verified List response.
: "${MRPC_API_KEY:?Set your owner key}"
: "${MRPC_COPIER_ID:?Set the copier ID}"
curl --fail-with-body --silent --show-error --max-time 30 \
  -H "ApiKey: ${MRPC_API_KEY}" --get \
  --data-urlencode "userKey=${MRPC_API_KEY}" \
  --data-urlencode "id=${MRPC_COPIER_ID}" \
  --data-urlencode 'paused=true' \
  'https://copy.mrpc.pro/CopierPause'
```

## Resume deliberately

Use the same Pause method with `false` (`paused: false` in Ruby). Check the reply and re-read List. A billing suspension can refuse a resume. Do not auto-resume every paused copier on application startup.

## Remove after inspection

Call the Remove method with the saved copier ID only after checking test positions and pending orders. Check the reply, then confirm the relationship no longer appears in List. Removal is not a substitute for closing positions.

For REST, use `/Remove` with `id`, `userKey`, and the `ApiKey` header. Inspect the JSON response as well as HTTP status. `/UserCopiers` lists the owner’s current relationships. The published [OpenAPI contract](https://copy.mrpc.pro/swagger/v1/swagger.json) describes the current REST routes and parameters.

## Monitor before trusting replication

Start/List/Pause/Remove tests validate management behavior. For a full acceptance test, open and close one demo position and compare both tickets, actual lots, and [trade logs](logs.md). See the [test checklist](testing.md).
