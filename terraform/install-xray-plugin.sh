#!/bin/bash
set -e

# This script installs the X-Ray plugin in AWS Managed Grafana
# It relies on the terraform output command to retrieve sensitive values

# Get the Grafana URL
GRAFANA_URL=$(terraform output -raw managed_grafana_endpoint)
if [ -z "$GRAFANA_URL" ]; then
  echo "Error: Could not retrieve Grafana URL from terraform output"
  exit 1
fi

# Get the API key directly from terraform output (prevents storing in state)
GRAFANA_API_KEY=$(terraform output -raw managed_grafana_api_key_secret)
if [ -z "$GRAFANA_API_KEY" ]; then
  echo "Error: Could not retrieve Grafana API key from terraform output"
  exit 1
fi

echo "Installing X-Ray plugin in $GRAFANA_URL..."
curl -X POST \
  -H "Authorization: Bearer $GRAFANA_API_KEY" \
  -H "Content-Type: application/json" \
  "https://$GRAFANA_URL/api/plugins/grafana-x-ray-datasource/install"

echo "Plugin installation command completed." 