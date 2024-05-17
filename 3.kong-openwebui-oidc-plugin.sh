#!/bin/bash

# Source the .env file
if [ -f .env ]; then
    source .env
else
    echo "Error: .env file not found. Please create a .env file with the necessary environment variables."
    exit 1
fi

# Function to check if an environment variable is set
check_env_var() {
    local var_name="$1"
    if [ -z "${!var_name}" ]; then
        echo "Error: Environment variable $var_name is not set. Please set it before running the script."
        exit 1
    fi
}

# Check required OIDC environment variables
check_env_var "AZURE_ENTRA_CLIENT_ID"
check_env_var "AZURE_ENTRA_CLIENT_SECRET"
check_env_var "AZURE_ENTRA_TENANT_ID"

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

curl -k -X POST http://localhost:8001/plugins \
    --data name=oidc \
    --data "instance_name=open-webui-plugin-oidc" \
    --data service.id=$service_id \
    --data route.id=$route_id \
    --data config.client_id=$AZURE_ENTRA_CLIENT_ID \
    --data config.client_secret=$AZURE_ENTRA_CLIENT_SECRET \
    --data config.discovery=https://login.microsoftonline.com/$AZURE_ENTRA_TENANT_ID/.well-known/openid-configuration \
    --data config.header_names[1]=X-User-Email \
    --data config.header_claims[1]=email \
    --data config.redirect_uri=/auth
