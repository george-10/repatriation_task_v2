#!/bin/bash

mv ../input.json .

oldSubscriptionName=$(jq -r '.oldSubscriptionName' input.json)
oldResourceGroup=$(jq -r '.oldResourceGroup' input.json)
newSubscriptionName=$(jq -r '.newSubscriptionName' input.json)
newResourceGroup=$(jq -r '.newResourceGroup' input.json)
newAppServiceName=$(jq -r '.newAppServiceName' input.json)
newSqlServerName=$(jq -r '.newSqlServerName' input.json)
newAppServiceSubnet=$(jq -r '.newAppServiceSubnet' input.json)
dbPassword=$(jq -r '.dbPassword' input.json)

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



# 1. Modify wwwroot
./modifyWordpressDirectory.sh 
# 2. 
