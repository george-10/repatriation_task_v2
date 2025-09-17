#!/bin/bash
if [ $# -ne 1 ]; then
  echo "Usage: $0 <resource-group-name>"
  exit 1
fi

PLAN_ID=$(az appservice plan list \
  --resource-group "$1" \
  --query "[0].id" \
  -o tsv)

echo "$PLAN_ID"
