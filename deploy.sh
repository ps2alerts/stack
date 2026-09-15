#!/bin/bash
# Deploys the production compose, monitoring config and host healthcheck to the ps2alerts box.
# Secrets never live in this repo: env files and the Erlang cookie stay on the host.
set -euo pipefail
HOST=ps2alerts
REMOTE=/root/docker

echo "Syncing files to $HOST"
scp -r monitoring/grafana/ $HOST:$REMOTE/files
scp -r monitoring/prometheus/ $HOST:$REMOTE/files/prometheus
scp docker/production/docker-compose.yml $HOST:$REMOTE/docker-compose.yml.new
scp docker/production/healthcheck.sh $HOST:/root/healthcheck.sh.new

ssh $HOST bash -s <<'REMOTE'
set -euo pipefail
cd /root/docker
cookie=$(grep -oE 'RABBITMQ_ERL_COOKIE: "[^"]+"' docker-compose.yml | head -1)
sed -i "s|RABBITMQ_ERL_COOKIE: \"REDACTED\"|$cookie|" docker-compose.yml.new
docker compose -f docker-compose.yml.new config -q
cp docker-compose.yml docker-compose.yml.bak
mv docker-compose.yml.new docker-compose.yml
bash -n /root/healthcheck.sh.new
cp /root/healthcheck.sh /root/healthcheck.sh.bak
mv /root/healthcheck.sh.new /root/healthcheck.sh
chmod 700 /root/healthcheck.sh
docker compose up -d --remove-orphans
REMOTE
echo "Done."
