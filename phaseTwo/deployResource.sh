#!/bin/bash
set -euo pipefail

WDIR="$HOME/repatriationTask/_work"

if [ "$#" -ne 3 ]; then
  echo "Usage: $0 <old-resource-name> <resource-group> <new-resource-name>"
  exit 1
fi

resourceName="$1"
resourceGroup="$2"
newResourceName="$3"

result=$(az resource list \
  --resource-group "$resourceGroup" \
  --query "[?name=='$newResourceName']" \
  --output tsv)

if [[ -n "$result" ]]; then
  echo "Resource '$newResourceName' already exists in resource group '$resourceGroup'. Stopping script."
  exit 0
else
  echo "Resource '$newResourceName' not found in '$resourceGroup'. Continuing script..."
fi

echo "Deploying template of $resourceName into resource group '$resourceGroup'..."
az deployment group create --resource-group "$resourceGroup" --template-file $WDIR/resources_template/$resourceName.json > $WDIR/resources/$resourceName.json

echo -e "Deployment complete.\n"
