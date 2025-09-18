#!/bin/bash

if [ $# -ne 7 ]; then
  echo "Usage: $0 <old-region> <new-region> <old-name> <new-name> <old-subnet-name> <new-subnet-name> <resource-group>"
  exit 1
fi

HDIR="$HOME/repatriationTask/helperFunctions"
WDIR="$HOME/repatriationTask/_work"

oldRegion=$1
newRegion=$2
oldName=$3
newName=$4
oldSubnet=$5
newSubnet=$6
resourceGroup=$7

echo "===== DEBUG INFO ====="
echo "HDIR: $HDIR"
echo "WDIR: $WDIR"
echo "oldRegion: $oldRegion"
echo "newRegion: $newRegion"
echo "oldName: $oldName"
echo "newName: $newName"
echo "oldSubnet: $oldSubnet"
echo "newSubnet: $newSubnet"
echo "resourceGroup: $resourceGroup"
echo "======================"

echo ">>> Step 1: Removing hostNameSslStates from Microsoft.Web/sites"
jq '(.resources[] | select(.type == "Microsoft.Web/sites") | .properties) |= del(.hostNameSslStates)' \
   $WDIR/resources_template/$oldName.json > tmp.json && mv tmp.json $WDIR/resources_template/$oldName.json
echo "Done Step 1."

echo ">>> Step 2: Removing Microsoft.Web/sites/hostNameBindings"
jq 'del(.resources[] | select(.type == "Microsoft.Web/sites/hostNameBindings"))' \
   $WDIR/resources_template/$oldName.json > tmp.json && mv tmp.json $WDIR/resources_template/$oldName.json
echo "Done Step 2."

echo ">>> Step 3: Updating App Service Plan ID"
appServicePlanId="$($HDIR/getAppServicePlanId.sh $resourceGroup)"
echo "App Service Plan ID: $appServicePlanId"
jq --arg id "$appServicePlanId" \
  '.parameters |= with_entries(if (.key | test("^serverfarms_.*_externalid$")) then .value.defaultValue = $id else . end)' \
  $WDIR/resources_template/$oldName.json > tmp.json && mv tmp.json $WDIR/resources_template/$oldName.json
echo "Done Step 3."

echo ">>> Step 4: Updating VNet ID"
vnetId="$($HDIR/getVnetId.sh $resourceGroup)"
echo "VNet ID: $vnetId"
jq --arg id "$vnetId" \
  '.parameters |= with_entries(
      if (.key | test("^virtualNetworks_.*_externalid$"))
      then .value.defaultValue = $id
      else .
      end
    )' \
  $WDIR/resources_template/$oldName.json > tmp.json && mv tmp.json $WDIR/resources_template/$oldName.json
echo "Done Step 4."

echo ">>> Step 5: Swapping values"
echo "Swapping $oldRegion -> $newRegion"
$HDIR/swapValues.sh "$oldRegion" "$newRegion" $WDIR/resources_template/$oldName.json

echo "Swapping $oldName -> $newName"
$HDIR/swapValues.sh "$oldName" "$newName" $WDIR/resources_template/$oldName.json

echo "Swapping $oldSubnet -> $newSubnet"
$HDIR/swapValues.sh "$oldSubnet" "$newSubnet" $WDIR/resources_template/$oldName.json

echo "All steps completed successfully."
