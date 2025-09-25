#!/bin/bash
set -euo pipefail

WDIR="$HOME/repatriationTask/_work"

mkdir -p $WDIR/resources_template

if [ $# -ne 2 ]; then
  echo "Usage: $0 <resource-group> <resource-name>"
  exit 1
fi

RG=$1
RN=$2

echo "Extracting template of $RN"
ids=$(az resource list --resource-group "$RG" --query "[?name=='$RN'].id" -o tsv)
n=$(echo -e "%s\n" "$ids" | grep -c . || true)

if [ "$n" -eq 0 ]; then
  echo -e "No resource named '$RN' found in resource group '$RG'. \n"
  exit 1
elif [ "$n" -gt 1 ]; then
  echo "Two or more resources named '$RN' in '$RG':"
  echo -e "%s\n" "$ids"
  echo -e "Cannot proceed. \n"
  exit 1
fi

echo $(az group export --name "$RG" --resource-ids $ids --skip-resource-name-params) > $WDIR/resources_template/$RN.json

echo -e "Template extracted to $WDIR/resources_template/$RN.json \n"
