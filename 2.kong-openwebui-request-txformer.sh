#!/bin/bash

# Check if jq is installed, suppressing stdout and stderr
if ! which jq > /dev/null 2>&1; then
  echo "jq is not installed. Please install jq first: brew install jq"
  exit 1
fi

# Define the route name you are looking for
route_name="open-webui-route"

# Get the route ID by name
route_id=$(curl -s http://localhost:8001/routes | jq -r --arg name "$route_name" '.data[] | select(.name == $name) | .id')

# Check if the route_id is not empty
if [ -z "$route_id" ]; then
  echo "Failed to find route ID for the route name: $route_name"
  exit 1
fi

curl -X POST http://localhost:8001/routes/$route_id/plugins \
  --data "name=request-transformer" \
  --data "config.add.headers[1]=X-User-Email:michael.tan@scbtechx.io"
