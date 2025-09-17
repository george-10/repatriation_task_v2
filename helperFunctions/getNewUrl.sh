#!/bin/bash


HDIR="$HOME/repatriationTask/helperFunctions"
WDIR="$HOME/repatriationTask/_work"

if [ $# -ne 1 ]; then
  echo "Usage: $0 <resource-group>"
  exit 1
fi
mkdir -p urls
[ -f $WDIR/urls/new_url.env ] && rm $WDIR/urls/new_url.env

rgName=$1


appName=$(az webapp list --resource-group "$rgName" --query '[0].name' -o tsv)

appUrl=$(az webapp show \
  --name "$appName" \
  --resource-group "$rgName" \
  --query "defaultHostName" \
  -o tsv)

echo "export NEW_URL=${appUrl}" > $WDIR/urls/new_url.env

echo "NEW_URL set to  $appUrl"
