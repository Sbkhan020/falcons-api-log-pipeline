#!/usr/bin/env bash
# Task 2 — verify Loki + Grafana are up and logs are in Loki. Read-only checks.
set -uo pipefail
echo "=== docker ps ==="; docker ps --format '{{.Names}} {{.Status}} {{.Ports}}'
echo "=== Loki ready ==="; curl -s http://localhost:3100/ready || echo "Loki not reachable"
echo "=== Grafana login ==="; curl -s -o /dev/null -w "%{http_code}\n" http://localhost:3000/login
echo "=== Logs in Loki (auth) ==="; curl -sf -G http://localhost:3100/loki/api/v1/query --data-urlencode 'query={log_source="auth.log"}' | python3 -m json.tool 2>/dev/null || echo "(could not parse JSON)"; echo
echo "=== Logs in Loki (api) ==="; curl -sf -G http://localhost:3100/loki/api/v1/query --data-urlencode 'query={log_source="api-access"}' | python3 -m json.tool 2>/dev/null || echo "(could not parse JSON)"; echo
echo "=== Logs in Loki (syslog) ==="; curl -sf -G http://localhost:3100/loki/api/v1/query --data-urlencode 'query={log_source="syslog"}' | python3 -m json.tool 2>/dev/null || echo "(could not parse JSON)"; echo
