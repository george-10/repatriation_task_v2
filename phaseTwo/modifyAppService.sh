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

echo "Modifying App Service template $oldName.json ..."
echo "Old Region: $oldRegion"
echo "New Region: $newRegion" 
echo "Old Name: $oldName"
echo "New Name: $newName"
echo "Old Subnet: $oldSubnet"
echo "New Subnet: $newSubnet"
echo "Resource Group: $resourceGroup"

jq '(.resources[] | select(.type == "Microsoft.Web/sites") | .properties) |= del(.hostNameSslStates)' \
   $WDIR/resources_template/$oldName.json > tmp.json && mv tmp.json $WDIR/resources_template/$oldName.json

jq 'del(.resources[] | select(.type == "Microsoft.Web/sites/hostNameBindings"))' \
   $WDIR/resources_template/$oldName.json > tmp.json && mv tmp.json $WDIR/resources_template/$oldName.json

$HDIR/swapValues.sh "$oldName" "$newName" $WDIR/resources_template/$oldName.json

appServicePlanId="$($HDIR/getAppServicePlanId.sh $resourceGroup)"
jq --arg id "$appServicePlanId" \
  '.parameters |= with_entries(if (.key | test("^serverfarms_.*_externalid$")) then .value.defaultValue = $id else . end)' \
  $WDIR/resources_template/$oldName.json > tmp.json && mv tmp.json $WDIR/resources_template/$oldName.json

vnetId="$($HDIR/getVnetId.sh $resourceGroup)"
jq --arg id "$vnetId" \
  '.parameters |= with_entries(
      if (.key | test("^virtualNetworks_.*_externalid$"))
      then .value.defaultValue = $id
      else .
      end
    )' \
  $WDIR/resources_template/$oldName.json > tmp.json && mv tmp.json $WDIR/resources_template/$oldName.json


$HDIR/swapValues.sh "$oldRegion" "$newRegion" $WDIR/resources_template/$oldName.json

$HDIR/swapValues.sh "/subnets/$oldSubnet" "/subnets/$newSubnet" $WDIR/resources_template/$oldName.json

echo -e "Modification complete.\n"


