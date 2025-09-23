#!/bin/bash

if [ $# -ne 3 ]; then
  echo "Usage: $0 <resource-group> <mysql-server-name> <db-password>"
  exit 1
fi
HDIR="$HOME/repatriationTask/helperFunctions"
WDIR="$HOME/repatriationTask/_work"

resourceGroup=$1
mysqlServerName=$2
dbPassword=$3

dbDatabase=$(az mysql flexible-server db list \
  --resource-group $resourceGroup \
  --server-name $mysqlServerName \
  --query "[?name!='information_schema' && name!='mysql' && name!='performance_schema' && name!='sys'].name" \
  -o tsv)
dbServerHostName="$mysqlServerName.mysql.database.azure.com"
dbUserName=$(cat $WDIR/dbUserName.txt)
echo "============================"
echo "Phase Three:"
echo "============================"
echo resourceGroup: $resourceGroup
echo mysqlServerName: $mysqlServerName
echo dbUserName: $dbUserName

echo "Getting New URL"

$HDIR/addFirewallRule.sh "$resourceGroup" "$mysqlServerName"
$HDIR/getNewUrl.sh $resourceGroup

echo "Modifying SQL Dump and WordPress Directory"
./modifySqlDump.sh
./modifyWordpressDirectory.sh $resourceGroup

echo "Deploying SQL Dump and WordPress Directory"
./deploySqlDump.sh $dbUserName $dbDatabase $dbPassword $dbServerHostName
./deployWordpressDirectory.sh $resourceGroup

$HDIR/removeFirewallRule.sh "$resourceGroup" "$mysqlServerName"
echo "Phase Three Completed"
