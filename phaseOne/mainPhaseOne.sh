#!/bin/bash
set -euo pipefail

WDIR="$HOME/repatriationTask/_work"
HDIR="$HOME/repatriationTask/helperFunctions"

if [ $# -lt 4 ]; then
  echo "Usage: $0 <resource-group> <app-service-name> <mysql-server-name> <db-password>"
  exit 1
fi

resourceGroup=$1
appServiceName=$2
mysqlServerName=$3
dbPassword=$4
appServicePlanName="$(az webapp show \
  --resource-group $resourceGroup \
  --name $appServiceName \
  --query appServicePlanId -o tsv | awk -F/ '{print $NF}'
)"

echo $appServicePlanName > $WDIR/appServicePlanName.txt

dbDatabase=$(az mysql flexible-server db list \
  --resource-group $resourceGroup \
  --server-name $mysqlServerName \
  --query "[?name!='information_schema' && name!='mysql' && name!='performance_schema' && name!='sys'].name" \
  -o tsv)
dbServerHostName="$3.mysql.database.azure.com"
echo "============================"
echo "Phase One:"
echo "============================\n\n"

#$HDIR/addFirewallRule.sh "$resourceGroup" "$mysqlServerName"

./extractArmTemplate.sh "$resourceGroup" "$appServicePlanName"
./extractArmTemplate.sh "$resourceGroup" "$appServiceName"
./extractArmTemplate.sh "$resourceGroup" "$mysqlServerName"
./extractRootDirectory.sh "$resourceGroup" "$appServiceName"
dbUserName=$(jq -r '.resources[] | select(.properties.administratorLogin != null) | .properties.administratorLogin' "$WDIR/resources_template/$mysqlServerName.json")

echo $dbUserName > $WDIR/dbUserName.txt

./extractSqlDump.sh $dbUserName $dbDatabase $dbPassword $dbServerHostName

$HDIR/getRegion.sh $resourceGroup > $WDIR/oldRegion.txt
$HDIR/getAppServiceSubnet.sh "$resourceGroup" "$appServiceName" > $WDIR/oldSubnetName.txt
#$HDIR/removeFirewallRule.sh "$resourceGroup" "$mysqlServerName"
echo "\n\nPhase One Completed\n\n"
