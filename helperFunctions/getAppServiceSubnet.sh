#!/bin/bash

if [ $# -ne 2 ]; then
  echo "Usage: $0 <resource-group> <app-service-name>"
  exit 1
fi

resourceGroup=$1
appServiceName=$2

subnetName=$(az webapp show \
  --name "$appServiceName" \
  --resource-group "$resourceGroup" \
  --query virtualNetworkSubnetId \
  -o tsv | awk -F/ '{print $NF}')

echo "$subnetName"
