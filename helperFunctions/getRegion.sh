#!/bin/bash
if [ $# -ne 1 ]; then
  echo "Usage: $0 <resource-group-name>"
  exit 1
fi

resourceGroup=$1

REGION=$(az account list-locations \
  --query "[?name=='$(az group show --name $resourceGroup --query location -o tsv)'].displayName" \
  -o tsv)

echo "$REGION"




