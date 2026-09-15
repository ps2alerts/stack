---
name: rabbit-dead-while-container-up
description: RabbitMQ can crash during queue-index recovery and leave the container "Up" with no broker; how it presents, the fix, and what now catches it
metadata:
  type: project
  volatility: durable
  lastVerified: 2026-09-15
---

After an unclean host reboot RabbitMQ's on-disk queue index can come back zero-filled. The
broker app then crashes during recovery (`rabbit_queue_index:parse_pub_record_body` throws
`badarg`) but the Erlang VM stays up, so `docker ps` shows `rabbit` as "Up" indefinitely.
Happened 2026-09-13; alerts stopped for ~45 hours before anyone noticed.

**How it presents:** collectors log `[RabbitMQ] Connection failed` every 5s while still
reporting "Connected to Census"; the aggregators crash-loop on `MQ Publisher queue did not
connect in time` and burn ~60% CPU each because every restart is a fresh `nest start`
compile (thousands of restarts). `docker exec rabbit rabbitmqctl status` says the `rabbit`
app is not running. The broker log names the corrupt queue directory.

**Fix:** `docker stop rabbit`, delete just that queue's directory under
`volumes/rabbitmq/rabbitmq/mnesia/rabbit@localhost/msg_stores/vhosts/<vhost-hash>/queues/`
(each directory's `.queue_name` file says which queue it is), `docker start rabbit`. The
apps re-assert their queues on connect. Only the pending messages in that one queue are lost;
the README's "wipe the whole mq volume" remedy is the blunt version of the same thing.

**Aftermath to clean:** alerts that started during the outage sit in `state: 0` ("failed to
start recording"), and the queued MetagameEvent backlog replays when the broker returns,
"ending" alerts with bogus 0/100/0 or 7/5/5 territory. Delete those
`instance_metagame_territories` docs and the matching `instance` rows in
`instance_facility_controls` and `aggregate_instance_*`. Per-alert queues for instances the
aggregator never tracked are left orphaned in Rabbit and need `rabbitmqctl delete_queue`.

**What catches it now:** every compose service has a healthcheck (rabbit's is
`rabbitmq-diagnostics check_running`, which fails in exactly this state), and
`docker/production/healthcheck.sh` runs the diagnostics itself every minute, requires a
consumer on the API and per-world MetagameEvent queues, and fails if no alert has recorded
for 12 hours. Verified by stopping the broker app in place: the cron check went red within a
minute, Docker's health state ~90s later.

Related: [[aggregator-health-endpoint-broken]].
