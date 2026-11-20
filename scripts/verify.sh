#!/usr/bin/env bash
# Task 2 — verify Loki + Grafana are up and logs are in Loki. Read-only checks.
# Deliberate: no -e in the flags below, so one failed label does not stop the loop.
set -uo pipefail
echo "=== docker ps ==="; docker ps --format '{{.Names}} {{.Status}} {{.Ports}}'
echo "=== Loki ready ==="; curl -s http://localhost:3100/ready || echo "Loki not reachable"
echo "=== Grafana login ==="; curl -s -o /dev/null -w "%{http_code}\n" http://localhost:3000/login
for label in auth.log api-access syslog; do
  echo "=== Logs in Loki ($label) ==="
  if out="$(curl -sf -G http://localhost:3100/loki/api/v1/query --data-urlencode "query={log_source=\"$label\"}")"; then
    printf '%s' "$out" | python3 -m json.tool 2>/dev/null || echo "(could not parse JSON)"
  else
    echo "(Loki query failed — check Loki is up and the label)"
  fi
done
