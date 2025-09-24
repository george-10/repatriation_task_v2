#!/bin/bash
set -euo pipefail

WDIR="$HOME/repatriationTask/_work"

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <resource-name> <resource-group>"
  exit 1
fi

resourceName="$1"
resourceGroup="$2"

echo "Deploying template of $resourceName into resource group '$resourceGroup'..."
az deployment group create --resource-group "$resourceGroup" --template-file $WDIR/resources_template/$resourceName.json > $WDIR/resources/$resourceName.json

echo "Deployment complete.\n"
