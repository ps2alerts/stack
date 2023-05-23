#!/bin/bash

container_name="ps2alerts-mq"
username="guest"
password="guest"
count=0

execute_after_start() {
  # Try to connect to RabbitMQ until it's online
  until $(curl --output /dev/null --silent --head --fail http://${username}:${password}@localhost:15672); do
    printf "Waiting for RabbitMQ to fully start...\n"
    sleep 1
  done

  # Create 'ps2alerts' direct exchange
  curl -i -u ${username}:${password} -H "content-type:application/json" -XPUT -d'{"type":"direct","auto_delete":false,"durable":true,"internal":false,"arguments":{}}' http://localhost:15672/api/exchanges/%2f/ps2alerts

  # Create 'ps2alerts-topic' topic exchange
  curl -i -u ${username}:${password} -H "content-type:application/json" -XPUT -d'{"type":"topic","auto_delete":false,"durable":true,"internal":false,"arguments":{}}' http://localhost:15672/api/exchanges/%2f/ps2alerts-topic

  # Check for existence of a fanout exchange named 'ps2alerts-census' in a loop
  while true; do
    response_census=$(curl --silent --write-out "HTTPSTATUS:%{http_code}" -u ${username}:${password} http://localhost:15672/api/exchanges/%2f/ps2alerts-census)

    body_census=${response_census%HTTPSTATUS:*}
    http_status_census=${response_census#*HTTPSTATUS:}

    if [ $http_status_census == 200 ]; then
      echo "'ps2alerts-census' exchange exists"
      break
    elif [ $http_status_census == 404 ]; then
      echo "'ps2alerts-census' exchange does not exist, checking again after 5 seconds"
      sleep 1
    else
      echo "Unknown error, response body: $body_census"
      exit 1
    fi
  done

  # Create a binding from 'ps2alerts-census' to 'ps2alerts-topic' with routing key 'my-routing-key'
  curl -i -u ${username}:${password} -H "content-type:application/json" -XPOST -d'{"routing_key":"","arguments":{}}' http://localhost:15672/api/bindings/%2f/e/ps2alerts-census/e/ps2alerts-topic

  echo "Setup complete!"
}

while true; do
  count=$((count + 1))
  echo "Run count: $count"

  docker events --format "{{json .}}" --filter type=container --since 5s --until 0s |
  while read -r line ; do
    event_container_name=$(echo $line | jq -r ".Actor.Attributes.name")
    status=$(echo $line | jq -r ".status")

    if [ "${status}" == "start" ] && [ "${event_container_name}" == "${container_name}" ]; then
      echo "Container $event_container_name changed state to $status"
      execute_after_start
    fi
  done

  sleep 5
done
