#!/usr/bin/env bash
# Task 2 — verify Loki + Grafana are up and logs are in Loki. Read-only checks.
set -u
echo "=== docker ps ==="; docker ps --format '{{.Names}} {{.Status}} {{.Ports}}'
echo "=== Loki ready ==="; curl -s http://localhost:3100/ready || echo "Loki not reachable"
echo "=== Grafana login ==="; curl -s -o /dev/null -w "%{http_code}\n" http://localhost:3000/login
echo "=== Logs in Loki (auth) ==="; curl -s -G http://localhost:3100/loki/api/v1/query --data-urlencode 'query={log_source="auth.log"}' | head -c 500; echo
echo "=== Logs in Loki (api) ==="; curl -s -G http://localhost:3100/loki/api/v1/query --data-urlencode 'query={log_source="api-access"}' | head -c 500; echo
echo "=== Logs in Loki (syslog) ==="; curl -s -G http://localhost:3100/loki/api/v1/query --data-urlencode 'query={log_source="syslog"}' | head -c 500; echo
