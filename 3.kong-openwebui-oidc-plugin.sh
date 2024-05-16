#!/bin/bash

# Check if jq is installed, suppressing stdout and stderr
if ! which jq > /dev/null 2>&1; then
  echo "jq is not installed. Please install jq first: brew install jq"
  exit 1
fi

# Define the service/route name you are looking for
service_name="open-webui-service"
route_name="open-webui-route"

# Get the service/route ID by name
service_id=$(curl -s http://localhost:8001/services | jq -r --arg name "$service_name" '.data[] | select(.name == $name) | .id')
route_id=$(curl -s http://localhost:8001/routes | jq -r --arg name "$route_name" '.data[] | select(.name == $name) | .id')

# Check if the service_id is not empty
if [ -z "$service_id" ]; then
  echo "Failed to find service ID for the service name: $service_name"
  exit 1
fi

# Check if the route_id is not empty
if [ -z "$route_id" ]; then
  echo "Failed to find route ID for the route name: $route_name"
  exit 1
fi

# Define OIDC Configuration
client_id=<AZURE_ENTRA_CLIENT_ID>
client_secret=<AZURE_ENTRA_CLIENT_SECRET>
tenant_id=<AZURE_ENTRA_TENANT_ID>

curl -k -X POST http://localhost:8001/plugins \
    --data name=oidc \
    --data instance_name=oidc \
    --data service.id=$service_id \
    --data route.id=$route_id \
    --data config.client_id=$client_id \
    --data config.client_secret=$client_secret \
    --data config.discovery=https://login.microsoftonline.com/$tenant_id/.well-known/openid-configuration \
    --data config.header_names[1]=X-User-Email \
    --data config.header_claims[1]=email \
    --data config.redirect_uri=/auth
