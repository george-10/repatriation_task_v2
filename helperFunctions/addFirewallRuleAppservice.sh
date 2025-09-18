#!/bin/bash

if [ $# -ne 3 ]; then
  echo "Usage: $0 <resource-group> <app-service-name> <mysql-server>"
  exit 1
fi

resourceGroup=$1
appServiceName=$2
mysqlServer=$3

hostName=$(az webapp show \
  --name "$appServiceName" \
  --resource-group "$resourceGroup" \
  --query defaultHostName \
  --output tsv)

while true; do
  ip=$(nslookup "$hostName" | awk '/^Address: / { print $2 }' | tail -n1)
  if [[ -n "$ip" ]]; then
    echo "Resolved IP: $ip"
    break
  else
    sleep 5
  fi
done

az mysql flexible-server firewall-rule create \
  --name "$mysqlServer" \
  --resource-group "$resourceGroup" \
  --rule-name "AllowAppServiceIP" \
  --start-ip-address "$ip" \
  --end-ip-address "$ip"
