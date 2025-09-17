#!/bin/bash

if [ $# -ne 5 ]; then
  echo "Usage: $0 <old-region> <new-region> <old-name> <new-name> <resource-group>"
  exit 1
fi

HDIR="$HOME/repatriationTask/helperFunctions"
WDIR="$HOME/repatriationTask/_work"

oldRegion=$1
newRegion=$2
oldName=$3
newName=$4
resourceGroup=$5

echo "Modify App Service Plan"

jq '(.resources[] | select(.type == "Microsoft.Web/sites") | .properties) |= del(.hostNameSslStates)' \
   $WDIR/resources_template/$oldName.json > tmp.json && mv tmp.json $WDIR/resources_template/$oldName.json

jq 'del(.resources[] | select(.type == "Microsoft.Web/sites/hostNameBindings"))' \
   ./resources_template/$oldName.json > tmp.json && mv tmp.json ./resources_template/$oldName.json

jq --arg id "$($HDIR/getAppServicePlanId.sh $resourceGroup)" \
  '.parameters |= with_entries(if (.key | test("^serverfarms_.*_externalid$")) then .value.defaultValue = $id else . end)' \
  $WDIR/resources_template/$oldName.json > tmp.json && mv tmp.json $WDIR/resources_template/$oldName.json

jq --arg id "$($HDIR/getVnetId.sh $resourceGroup)" \
  '.parameters |= with_entries(
      if (.key | test("^virtualNetworks_.*_externalid$"))
      then .value.defaultValue = $id
      else .
      end
    )' \
  $WDIR/resources_template/$oldName.json > tmp.json && mv tmp.json $WDIR/resources_template/$oldName.json


$HDIR/swapValues.sh "$oldRegion" "$newRegion" $WDIR/resources_template/$oldName.json
$HDIR/swapValues.sh "$oldName" "$newName" $WDIR/resources_template/$oldName.json
