#!/bin/bash

container_name="ps2alerts-mq"
username="guest"
password="guest"

execute_after_start () {
  # Create the standard 'ps2alerts' exchange if it doesn't exist
  curl -i -u ${username}:${password} -H "content-type:application/json" -XPUT -d'{"type":"direct","auto_delete":false,"durable":true,"internal":false,"arguments":{}}' http://localhost:15672/api/exchanges/%2f/ps2alerts

  # Create the 'ps2alerts-topic' topic exchange if it doesn't exist
  curl -i -u ${username}:${password} -H "content-type:application/json" -XPUT -d'{"type":"topic","auto_delete":false,"durable":true,"internal":false,"arguments":{}}' http://localhost:15672/api/exchanges/%2f/ps2alerts-topic

  # Create the binding from 'ps2alerts-census' to 'ps2alerts-topic' with no routing key
  curl -i -u ${username}:${password} -H "content-type:application/json" -XPOST -d'{"routing_key":"","arguments":{}}' http://localhost:15672/api/bindings/%2f/e/ps2alerts-census/e/ps2alerts-topic
}

while true; do
  # Check if the Docker container is running
  if [ "$(docker inspect -f {{.State.Running}} $container_name)" == "true" ]; then

    # Retrieve the bindings
    response=$(curl --silent -u ${username}:${password} http://localhost:15672/api/bindings)

    # Check if the required binding exists
    binding_exists=$(echo $response | jq '.[] | select(.source == "ps2alerts-census" and .destination == "ps2alerts-topic")')

    if [ -z "$binding_exists" ]; then
      echo "$(date) - Binding does not exist, creating..."
      execute_after_start
      echo "$(date) - Binding created"
    else
      echo "$(date) - Binding exists"
    fi

  else
    echo "$(date) - Docker container is not running"
  fi

  sleep 15
done
