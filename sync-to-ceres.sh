#!/bin/bash

echo "Syncing files to Ceres"

scp -r monitoring/grafana/ server@10.0.5.2:/home/server/docker/ps2alerts/production/files
scp -r monitoring/prometheus/ server@10.0.5.2:/home/server/docker/ps2alerts/production/files/prometheus
ssh server@10.0.5.2 'docker restart ps2alerts-grafana'
