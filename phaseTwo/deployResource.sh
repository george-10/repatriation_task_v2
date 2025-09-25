#!/bin/bash
set -euo pipefail

WDIR="$HOME/repatriationTask/_work"

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <resource-name> <resource-group>"
  exit 1
fi

resourceName="$1"
resourceGroup="$2"

result=$(az resource list \
  --resource-group "$resourceGroup" \
  --query "[?name=='$resourceName']" \
  --output tsv)

if [[ -n "$result" ]]; then
  echo "Resource '$resourceName' already exists in resource group '$resourceGroup'. Stopping script."
  exit 0
else
  echo "Resource '$resourceName' not found in '$resourceGroup'. Continuing script..."
fi

echo "Deploying template of $resourceName into resource group '$resourceGroup'..."
az deployment group create --resource-group "$resourceGroup" --template-file $WDIR/resources_template/$resourceName.json > $WDIR/resources/$resourceName.json

echo -e "Deployment complete.\n"
