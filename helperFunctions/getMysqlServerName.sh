#!/bin/bash
if [ -z "$1" ]; then
  echo "Usage: $0 <resource-group-name>"
  exit 1
fi

RESOURCE_GROUP=$1
az mysql flexible-server list --resource-group "$RESOURCE_GROUP" --query "[].name" --output tsv
