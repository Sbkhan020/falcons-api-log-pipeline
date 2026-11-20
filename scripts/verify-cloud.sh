#!/usr/bin/env bash
# Task 2 — verify logs in Grafana CLOUD Loki (verify.sh only checks LOCAL Loki).
# Usage: CLOUD_LOKI_URL='https://logs-prod-XXX.grafana.net/loki/api/v1/query' \
#        CLOUD_USER_ID='<numeric user id>' CLOUD_API_TOKEN='<token>' ./scripts/verify-cloud.sh
# Never commit real values, and never paste the token in the supervisor chat.
# NOTE: until Promtail's clients: is changed to the Cloud push endpoint,
# this script will return empty for all three labels — that is expected,
# not a failure, because Promtail still pushes to the local Loki.
# Security: the token is never put on the command line (no -u / --user with
# the token in it — it would land in shell history and in `ps`). Instead it
# goes into a temp curl config file (0600, deleted on exit), read by curl -K.
# Token type: Grafana Cloud Loki push uses basic auth (user ID + API token),
# not a Bearer service-account token, so basic auth in the config file is
# the right form here; re-check when the Cloud stack is created.
# Deliberate: no -e in the flags below, so one failed label does not stop
# the loop — the script checks all three labels and reports each one.
set -uo pipefail
: "${CLOUD_LOKI_URL:?set CLOUD_LOKI_URL}"
: "${CLOUD_USER_ID:?set CLOUD_USER_ID}"
: "${CLOUD_API_TOKEN:?set CLOUD_API_TOKEN}"
cfg="$(mktemp)"; chmod 600 "$cfg"
printf 'user = "%s:%s"\n' "$CLOUD_USER_ID" "$CLOUD_API_TOKEN" > "$cfg"
trap 'rm -f "$cfg"' EXIT
for label in auth.log syslog api-access; do
  echo "=== Cloud Loki: $label ==="
  # Check curl's exit code separately: with -f a 401/404 exits non-zero,
  # and piping straight to json.tool would hide that (it parses empty input as OK).
  if out="$(curl -sf -K "$cfg" -G "$CLOUD_LOKI_URL" --data-urlencode "query={log_source=\"$label\"}")"; then
    printf '%s' "$out" | python3 -m json.tool 2>/dev/null || echo "(could not parse JSON)"
  else
    echo "(Cloud query failed — check the Cloud endpoint and credentials)"
  fi
done
