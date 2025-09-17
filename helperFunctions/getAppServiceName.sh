#!/bin/bash
if [ -z "$1" ]; then
  echo "Usage: $0 <resource-group-name>"
  exit 1
fi

RESOURCE_GROUP=$1
az webapp list --resource-group "$RESOURCE_GROUP" --query "[].name" --output tsv
