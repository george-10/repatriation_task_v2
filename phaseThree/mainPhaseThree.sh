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


dbPassword=$4
dbDatabase=$(az mysql flexible-server db list \
  --resource-group $resourceGroup \
  --server-name $mysqlServerName \
  --query "[?name!='information_schema' && name!='mysql' && name!='performance_schema' && name!='sys'].name" \
  -o tsv)
dbServerHostName="$3.mysql.database.azure.com"
dbUserName=$(jq -r '.resources[] | select(.properties.administratorLogin != null) | .properties.administratorLogin' "$WDIR/resources_template/$mysqlServerName.json")


echo "Phase Three:"
echo "Modifying SQL Dump and WordPress Directory"
./modifySqlDump.sh 
./modifyWordpressDirectory.sh $resourceGroup

echo "Deploying SQL Dump and WordPress Directory"
./deploySqlDump.sh $dbUserName $dbDatabase $dbPassword $dbServerHost
./deployWordpressDirectory.sh $resourceGroup

echo "Phase Three Completed"