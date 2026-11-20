#!/usr/bin/env bash
# Task 2 — verify logs in Grafana CLOUD Loki (verify.sh only checks LOCAL Loki).
# Usage: CLOUD_LOKI_URL='https://logs-prod-XXX.grafana.net/loki/api/v1/query' \
#        CLOUD_USER_ID='<numeric user id>' CLOUD_API_TOKEN='<token>' ./scripts/verify-cloud.sh
# Never commit real values, and never paste the token in the supervisor chat.
set -u
: "${CLOUD_LOKI_URL:?set CLOUD_LOKI_URL}"
: "${CLOUD_USER_ID:?set CLOUD_USER_ID}"
: "${CLOUD_API_TOKEN:?set CLOUD_API_TOKEN}"
for label in auth.log syslog api-access; do
  echo "=== Cloud Loki: $label ==="
  curl -s -G -u "$CLOUD_USER_ID:$CLOUD_API_TOKEN" "$CLOUD_LOKI_URL" \
    --data-urlencode "query={log_source=\"$label\"}" | head -c 500; echo
done
