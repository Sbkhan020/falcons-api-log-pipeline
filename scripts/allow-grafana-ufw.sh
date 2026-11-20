#!/usr/bin/env bash
# Task 2 — allow Grafana through the Task 1 UFW firewall.
# Task 1 UFW allowed only 22, 80, 443, so port 3000 was blocked.
# Run on the Ubuntu VM with sudo, after Task 1 hardening.
set -euo pipefail
sudo ufw allow 3000/tcp comment 'Grafana'
sudo ufw status verbose
echo "Grafana should now be reachable at http://localhost:3000 (or http://<vm-ip>:3000)"
