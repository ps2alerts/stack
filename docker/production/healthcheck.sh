#!/usr/bin/env bash
# Host-level healthcheck, run from root's crontab every minute. Pings healthchecks.io on
# success, posts the failure list to /fail otherwise. Deployed to /root/healthcheck.sh.
set -o errexit
set -o nounset
set -o pipefail

# = CONFIGURATION ===============================
ENV_FILE=/root/healthcheck.env          # PING_URL, PUSHOVER_API_TOKEN, PUSHOVER_USER_KEY
LOCK_FILE=/var/lock/healthcheck.lock
STATE_FILE=/var/tmp/healthcheck.restarts
MIN_FREE_GB=10
MIN_FREE_BOOT_MB=50
EXCLUDE_REGEX='^/(sys|run|dev|proc)'
DOCKER_TIMEOUT=30
MAX_ALERT_GAP_HOURS=12               # PS2 never goes this long without an alert on some world
ALERT_GAP_NOTIFY_INTERVAL=21600      # seconds between repeat Pushover pings for the same gap
ALERT_GAP_STAMP=/var/tmp/healthcheck.alert-gap-notified
CONTAINERS=(
  website assets
  api-rest api-cron api-aggregator
  collector-pc collector-ps4eu collector-ps4us
  aggregator-pc aggregator-ps4eu aggregator-ps4us
  db rabbit redis prometheus grafana
)
# Queues that must have a consumer whenever the stack is healthy.
CONSUMED_QUEUES=(
  api-queue-production
  aggregator-1-MetagameEvent aggregator-10-MetagameEvent aggregator-13-MetagameEvent
  aggregator-17-MetagameEvent aggregator-40-MetagameEvent
  aggregator-1000-MetagameEvent aggregator-2000-MetagameEvent
)
REDIS_CONTAINER=redis
RECOVERY_SCRIPT=/root/bonk-redis.sh
RECOVERY_TIMEOUT=90
RECOVERY_INTERVAL=5

# shellcheck disable=SC1090
source "$ENV_FILE"
FAIL_ENDPOINT="${PING_URL}/fail"
FAILURES=()

# = HELPERS =====================================
fail_now() {
  local message="$1"
  echo "[FAIL] ${message}" >&2
  curl -fsS --retry 2 --retry-delay 1 -d "$message" "$FAIL_ENDPOINT" >/dev/null || true
  exit 1
}

add_failure() {
  echo "[FAIL] $1" >&2
  FAILURES+=("$1")
}

dk() { timeout "$DOCKER_TIMEOUT" docker "$@"; }

notify_pushover() {
  local title="$1" message="$2"
  curl -fsS \
    --form-string "token=${PUSHOVER_API_TOKEN}" \
    --form-string "user=${PUSHOVER_USER_KEY}" \
    --form-string "title=${title}" \
    --form-string "message=${message}" \
    --form-string "priority=0" \
    https://api.pushover.net/1/messages.json >/dev/null || true
}

container_status() { dk inspect --format '{{.State.Status}}' "$1" 2>/dev/null || echo missing; }
container_health() {
  dk inspect --format '{{if .State.Health}}{{.State.Health.Status}}{{else}}none{{end}}' "$1" 2>/dev/null || echo missing
}
container_restarts() { dk inspect --format '{{.RestartCount}}' "$1" 2>/dev/null || echo 0; }

attempt_redis_recovery() {
  local reason="$1"
  echo "[RECOVERY] Redis issue detected: ${reason}. Running recovery script..."
  if ! bash "$RECOVERY_SCRIPT"; then
    fail_now "Recovery script '${RECOVERY_SCRIPT}' failed (original issue: ${reason})"
  fi
  local waited=0
  while (( waited < RECOVERY_TIMEOUT )); do
    sleep "$RECOVERY_INTERVAL"
    waited=$(( waited + RECOVERY_INTERVAL ))
    local status health
    status=$(container_status "$REDIS_CONTAINER")
    health=$(container_health "$REDIS_CONTAINER")
    if [[ "$status" == "running" && ( "$health" == "healthy" || "$health" == "none" ) ]]; then
      echo "[RECOVERY] Redis recovered after ${waited}s."
      notify_pushover "Redis Auto-Recovery" \
        "Redis recovered automatically after ${waited}s.\nOriginal issue: ${reason}\nHost: $(hostname)"
      return 0
    fi
  done
  fail_now "Redis did not recover within ${RECOVERY_TIMEOUT}s (original issue: ${reason})"
}

# = LOCK ========================================
# A redis recovery can outlast the cron interval; never let two runs overlap.
exec 9>"$LOCK_FILE"
if ! flock -n 9; then
  echo "another healthcheck run holds the lock, skipping" >&2
  exit 0
fi

# = DOCKER DAEMON ===============================
dk info >/dev/null 2>&1 || fail_now "Docker daemon is unreachable"

# = REDIS RECOVERY ==============================
# Runs first so the generic container check below sees the recovered state.
redis_status=$(container_status "$REDIS_CONTAINER")
redis_health=$(container_health "$REDIS_CONTAINER")
if [[ "$redis_status" == "restarting" ]]; then
  attempt_redis_recovery "container in restart loop"
elif [[ "$redis_status" == "running" && "$redis_health" == "unhealthy" ]]; then
  attempt_redis_recovery "container unhealthy"
fi

# = CONTAINERS ==================================
declare -A previous_restarts=()
if [[ -f "$STATE_FILE" ]]; then
  while IFS='=' read -r name count; do
    [[ -n "$name" ]] && previous_restarts["$name"]="$count"
  done < "$STATE_FILE"
fi
: > "${STATE_FILE}.tmp"

for c in "${CONTAINERS[@]}"; do
  status=$(container_status "$c")
  health=$(container_health "$c")
  restarts=$(container_restarts "$c")
  echo "${c}=${restarts}" >> "${STATE_FILE}.tmp"

  if [[ "$status" != "running" ]]; then
    add_failure "${c}: not running (status: ${status})"
    continue
  fi
  if [[ "$health" == "unhealthy" ]]; then
    add_failure "${c}: unhealthy"
  fi
  prev=${previous_restarts[$c]:-$restarts}
  if (( restarts - prev >= 2 )); then
    add_failure "${c}: crash-looping (${prev} -> ${restarts} restarts in the last minute)"
  fi
done
mv "${STATE_FILE}.tmp" "$STATE_FILE"

# = RABBITMQ ====================================
# "Up" is not enough: the broker app can crash during recovery and leave the container running.
if [[ $(container_status rabbit) == "running" ]]; then
  for check in check_running check_local_alarms check_port_connectivity; do
    if ! dk exec rabbit rabbitmq-diagnostics -q "$check" >/dev/null 2>&1; then
      add_failure "rabbit: rabbitmq-diagnostics ${check} failed"
    fi
  done
  if queue_list=$(dk exec rabbit rabbitmqctl -q list_queues name consumers 2>/dev/null); then
    for q in "${CONSUMED_QUEUES[@]}"; do
      consumers=$(awk -v q="$q" '$1 == q {print $2; exit}' <<<"$queue_list")
      if [[ -z "$consumers" ]]; then
        add_failure "rabbit: queue ${q} does not exist"
      elif ! [[ "$consumers" =~ ^[0-9]+$ ]] || (( consumers < 1 )); then
        add_failure "rabbit: queue ${q} has no consumer"
      fi
    done
  else
    add_failure "rabbit: rabbitmqctl list_queues failed"
  fi
fi

# = LAST RECORDED ALERT =========================
# state 0 is an alert that failed to record, so it does not count as evidence the pipeline works.
last_alert=$(dk exec db sh -c 'mongosh --quiet -u "$MONGODB_USERNAME" -p "$MONGODB_PASSWORD" \
  --authenticationDatabase "$MONGODB_DATABASE" "$MONGODB_DATABASE" --eval \
  "const d = db.instance_metagame_territories.find({state:{\$ne:0}},{timeStarted:1}).sort({timeStarted:-1}).limit(1).next(); print(d ? d.timeStarted.getTime() : 0)"' 2>/dev/null || echo error)
if [[ "$last_alert" =~ ^[0-9]+$ ]]; then
  gap_hours=$(( ( $(date +%s) - last_alert / 1000 ) / 3600 ))
  if (( gap_hours >= MAX_ALERT_GAP_HOURS )); then
    add_failure "no alert recorded for ${gap_hours}h (last: $(date -u -d @$(( last_alert / 1000 )) +%FT%TZ))"
    last_notified=$(cat "$ALERT_GAP_STAMP" 2>/dev/null || echo 0)
    if (( $(date +%s) - last_notified >= ALERT_GAP_NOTIFY_INTERVAL )); then
      notify_pushover "PS2Alerts: no alerts for ${gap_hours}h" \
        "Last recorded alert started $(date -u -d @$(( last_alert / 1000 )) +%FT%TZ). Collectors, rabbit or the aggregators are probably wedged.\nHost: $(hostname)"
      date +%s > "$ALERT_GAP_STAMP"
    fi
  else
    rm -f "$ALERT_GAP_STAMP"
  fi
else
  add_failure "db: could not read last alert time (${last_alert})"
fi

# = PUBLISHED PORTS =============================
curl -fsS -m 10 -o /dev/null http://127.0.0.1:81/healthcheck || add_failure "api-rest: /healthcheck on :81 failed"
curl -fsS -m 10 -o /dev/null http://127.0.0.1:80/ || add_failure "website: / on :80 failed"

# = DISK ========================================
while read -r mount avail_mb; do
  free_mb=${avail_mb%M}
  (( free_mb < MIN_FREE_BOOT_MB )) && add_failure "${mount} has only ${free_mb} MB free (threshold: ${MIN_FREE_BOOT_MB} MB)"
done < <(df --output=target,avail -BM | awk -v re="$EXCLUDE_REGEX" 'NR>1 && $1 ~ /^\/boot/ && $1 !~ re')
while read -r mount avail_gb; do
  free_gb=${avail_gb%G}
  (( free_gb < MIN_FREE_GB )) && add_failure "${mount} has only ${free_gb} GB free (threshold: ${MIN_FREE_GB} GB)"
done < <(df --output=target,avail -BG | awk -v re="$EXCLUDE_REGEX" 'NR>1 && $1 !~ /^\/boot/ && $1 !~ re')

# = RESULT ======================================
if (( ${#FAILURES[@]} > 0 )); then
  fail_now "$(printf '%s\n' "${FAILURES[@]}")"
fi
curl -fsS --retry 2 --retry-delay 1 "$PING_URL" >/dev/null
exit 0
