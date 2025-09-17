#!/bin/bash
if [ $# -ne 1 ]; then
  echo "Usage: $0 <resource-group-name>"
  exit 1
fi

VNET_ID=$(az network vnet list \
  --resource-group "$1" \
  --query "[0].id" \
  -o tsv)

echo "$VNET_ID"
