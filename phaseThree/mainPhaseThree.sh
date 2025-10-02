#!/bin/bash

if [ $# -ne 4 ]; then
  echo "Usage: $0 <resource-group> <mysql-server-name> <db-password> <old-domain-name>"
  exit 1
fi
HDIR="$HOME/repatriationTask/helperFunctions"
WDIR="$HOME/repatriationTask/_work"
CONFIG_FILE="$WDIR/wwwroot/wp-config.php"

$HDIR/getNewUrl.sh $resourceGroup
source "$WDIR/urls/new_url.env"

resourceGroup=$1
mysqlServerName=$2
dbPassword=$3
oldDomainName=$4

$HDIR/getNewUrl.sh $resourceGroup
source "$WDIR/urls/new_url.env"

dbDatabase=$(grep "define( [\"']DB_NAME[\"']" "$CONFIG_FILE" | sed "s/.*'DB_NAME', *'\([^']*\)'.*/\1/")
dbServerHostName="$mysqlServerName.mysql.database.azure.com"
dbUserName=$(cat $WDIR/dbUserName.txt)
echo "============================"
echo "Phase Three:"
echo -e "============================\n\n"
echo resourceGroup: $resourceGroup
echo mysqlServerName: $mysqlServerName
echo dbUserName: $dbUserName

echo "Getting New URL"

#$HDIR/addFirewallRule.sh "$resourceGroup" "$mysqlServerName"


echo "Modifying SQL Dump and WordPress Directory"
./modifySqlDump.sh $oldDomainName $NEW_URL
./modifyWordpressDirectory.sh $resourceGroup 

echo "Deploying SQL Dump and WordPress Directory"
./deploySqlDump.sh $dbUserName $dbDatabase $dbPassword $dbServerHostName
./deployWordpressDirectory.sh $resourceGroup

./addPermissions.sh $dbUserName $dbPassword
#$HDIR/removeFirewallRule.sh "$resourceGroup" "$mysqlServerName"

