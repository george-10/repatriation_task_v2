#!/bin/bash

set -e

HDIR="$HOME/repatriationTask/helperFunctions"
WDIR="$HOME/repatriationTask/_work"

mkdir -p $WDIR/resources
appServiceName=$(jq -r '.newAppServiceName' input.json)
oldSubscriptionName=$(jq -r '.oldSubscriptionName' input.json)
oldResourceGroup=$(jq -r '.oldResourceGroup' input.json)
newSubscriptionName=$(jq -r '.newSubscriptionName' input.json)
newResourceGroup=$(jq -r '.newResourceGroup' input.json)
newAppServiceName="$appServiceName-APP01"
newSqlServerName=$(jq -r '.newSqlServerName' input.json)
newAppServiceSubnet=$(jq -r '.newAppServiceSubnet' input.json)
dbPassword=$(jq -r '.dbPassword' input.json)

appServicePlanName=$(cat $WDIR/appServicePlanName.txt)
newAppServicePlanName="$appServiceName-ASP01"
if jq -e 'has("oldAppServiceName")' input.json > /dev/null; then
  oldAppServiceName=$(jq -r '.oldAppServiceName' input.json)
else
  echo "oldAppServiceName not found in input.json, fetching with helper script..."
  oldAppServiceName=$($DIR/helperFunctions/getAppServiceName.sh "$oldResourceGroup")
fi

if jq -e 'has("oldSqlServerName")' input.json > /dev/null; then
  oldSqlServerName=$(jq -r '.oldSqlServerName' input.json)
else
  echo "oldSqlServerName not found in input.json, fetching with helper script..."
  oldSqlServerName=$($DIR/helperFunctions/getSqlServerName.sh "$oldResourceGroup")
fi


oldRegion=$(cat $WDIR/oldRegion.txt)
newRegion=$($HDIR/getRegion.sh "$newResourceGroup")
oldAppServiceSubnet=$(cat $WDIR/oldSubnetName.txt)
echo "============================"
echo "Phase Two:"
echo "============================"
./modifyAppServicePlan.sh "$oldRegion" "$newRegion" "$appServicePlanName" "$newAppServicePlanName"
./deployResource.sh "$appServicePlanName" "$newResourceGroup"

./modifyAppService.sh "$oldRegion" "$newRegion" "$oldAppServiceName" "$newAppServiceName" "$oldAppServiceSubnet" "$newAppServiceSubnet" "$newResourceGroup"
./deployResource.sh "$oldAppServiceName" "$newResourceGroup"

./modifyDatabase.sh "$oldRegion" "$newRegion" "$oldSqlServerName" "$newSqlServerName" "$dbPassword"
./deployResource.sh "$oldSqlServerName" "$newResourceGroup"
$HDIR/addFirewallRuleAppservice.sh "$newResourceGroup" "$newAppServiceName" "$newSqlServerName"

rm input.json
echo "Phase Two Completed"
