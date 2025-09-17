#!/bin/bash
set -euo pipefail

if [ $# -lt 2 ]; then
  echo "Usage: $0 <resource-group> <mysql-server-name>"
  exit 1
fi

resourceGroup=$1
mysqlServer=$2
myIp=$(curl -s ifconfig.me)

echo "Adding firewall rule for current IP ($myIp) on server $mysqlServer in resource group $resourceGroup"

az mysql flexible-server firewall-rule create \
  --name "$mysqlServer" \
  --resource-group "$resourceGroup" \
  --rule-name "AllowMyIP" \
  --start-ip-address "$myIp" \
  --end-ip-address "$myIp"
