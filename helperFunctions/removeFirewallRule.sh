#!/bin/bash
set -euo pipefail

if [ $# -lt 2 ]; then
  echo "Usage: $0 <resource-group> <mysql-server-name>"
  exit 1
fi

resourceGroup=$1
mysqlServer=$2

echo "Removing firewall rule 'AllowMyIP' from server $mysqlServer in resource group $resourceGroup"

az mysql flexible-server firewall-rule delete \
  --name "$mysqlServer" \
  --resource-group "$resourceGroup" \
  --rule-name "AllowMyIP" \
  --yes
