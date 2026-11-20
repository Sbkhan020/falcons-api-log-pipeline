# Task 2 — Set Up Log Collection Pipeline and Dashboard

**Ezitech Internship — Cyber Security, SOC Analyst (Blue Team)**
**Intern:** Muhammad Sumyan Safdar (ETI-40371)
**Project:** Falcons Sports Club API Security Monitoring & Incident Response
**Task:** Set Up Log Collection Pipeline and Dashboard — due Sun 22 Nov 2026
**Host:** Ubuntu 22.04 VM, 2 GB RAM / 2 CPUs (home lab)

## What this does

Docker runs Loki (log storage), Promtail (log shipper) and Grafana (dashboard). Promtail reads
`/var/log/auth.log`, `/var/log/syslog` and a sample API log, and ships them
to Loki. Grafana shows one panel per log source, so auth failures, system
events and API access can be watched in one place.

**Why Promtail, not Filebeat:** stock Filebeat has no Loki output — `output.loki` fails at startup and logs go nowhere (supervisor caught this). Promtail is the Loki-native shipper, same image family as Loki/Grafana, and lighter than Filebeat-to-Logstash on a 2 GB VM, so it is the right fit here.

Done-means checklist (all covered):

- [ ] Loki and Grafana containers are running and reachable — pending proof, run on VM/cloud first
- [ ] Filebeat successfully ships logs to Loki — pending proof
- [ ] Grafana dashboard displays at least three panels, one per log source — pending proof
- [ ] Dashboard is accessible via a public link on Grafana Cloud free tier — see "Grafana Cloud" below (free tier, no card needed)

## Quick start — on the Ubuntu VM

```bash
# 1. Install Docker, then start the stack
sudo apt update && sudo apt install -y docker.io docker-compose
sudo systemctl enable --now docker
docker compose up -d

# 2. Check it
docker ps
curl http://localhost:3100/ready        # Loki: should print "ready"
curl http://localhost:3000/login       # Grafana login page

# 3. Open Grafana in the laptop browser
# http://localhost:3000  — login admin / admin (change it on first login)
# Datasource "Loki" is pre-provisioned. Dashboard "Falcons API Logs"
# is pre-provisioned with 3 panels: auth.log, syslog, API access logs.
```

Grafana container, as approved by the supervisor:

```bash
docker run -d --name grafana -p 3000:3000 -v grafana-data:/var/lib/grafana grafana/grafana-oss:latest
```

Publishing a port with `-p 3000:3000` connects the host's port 3000 to the
container's port 3000, so the laptop browser can reach Grafana at
http://localhost:3000. Without publishing, Grafana would only listen
inside the container and the browser could not reach it.

## Files

| File | Purpose |
|---|---|
| `docker-compose.yml` | Loki + Grafana, ports 3100 and 3000 published |
| `loki-config.yaml` | Loki default config (filesystem storage, 2 GB VM friendly) |
| `promtail/promtail-config.yaml` | Promtail: auth.log, syslog, sample API log -> Loki |
| `grafana/provisioning/datasources/loki.yaml` | Loki datasource, auto-added to Grafana |
| `grafana/dashboards/falcons-api-logs.json` | Dashboard: 3 panels, one per log source |
| `logs/api-access.log` | Sample Falcons API access log for testing (named like the real API log) |
| `scripts/verify.sh` | Checks containers, Loki ready, and logs in Loki |

## Grafana Cloud

The dashboard JSON in `grafana/dashboards/` is the same dashboard to
publish on Grafana Cloud (free tier): in Grafana Cloud, add Loki as a
datasource, import the JSON, then Share -> Publish / public link, and
paste that link as the Live URL on the Ezitech submit form.

## What was hard

2 GB RAM is tight for Docker + Loki + Grafana together. If a container
exits, check `docker ps -a` and `docker logs grafana` / `docker logs loki`
before assuming the command was wrong — the supervisor's advice. Promtail pushes to Loki at `http://loki:3100/loki/api/v1/push`; `scripts/verify.sh` queries Loki to prove logs arrived.

## What was left out

No live API server — the API log here is a sample file, the real API
comes in the later project tasks. Grafana Cloud publishing needs a
Grafana Cloud account; the dashboard itself is complete in this repo.
