#!/bin/bash

WDIR="$HOME/repatriationTask/_work"

if [ $# -ne 2 ]; then
  echo "Usage: $0 <resource-group> <app-service-name>"
  exit 1
fi

rgName=$1
appName=$2

username=$(az webapp deployment list-publishing-profiles \
  --name "$appName" \
  --resource-group "$rgName" \
  --query "[?publishMethod=='FTP'].[userName]" \
  -o tsv)

password=$(az webapp deployment list-publishing-profiles \
  --name "$appName" \
  --resource-group "$rgName" \
  --query "[?publishMethod=='FTP'].[userPWD]" \
  -o tsv)

ftpsUrl=$(az webapp deployment list-publishing-profiles \
  --name "$appName" \
  --resource-group "$rgName" \
  --query "[?publishMethod=='FTP'].[publishUrl]" \
  -o tsv)

host=$(echo "$ftpsUrl" | sed -E 's|^ftps://([^/]+)/.*|\1|')

mkdir -p "$WDIR/urls"
[ -f $WDIR/urls/old_url.env ] && rm $WDIR/urls/old_url.env


appUrl=$(az webapp show \
  --name "$appName" \
  --resource-group "$rgName" \
  --query "defaultHostName" \
  -o tsv)

echo "export OLD_URL=${appUrl}" > $WDIR/urls/old_url.env

echo "OLD_URL set to ${appUrl}"

echo "Connecting to App Service: $appName"
echo "Host: $host"
echo "User: $username"
echo "Password: $password"
lftp -u "$username","$password" "$host" -e "
  set ftp:ssl-force true;
  set ftp:ssl-protect-data true;
  set ftp:passive-mode true;
  set ssl:verify-certificate no;
  set net:max-retries 2;
  set net:timeout 30;
  mirror --verbose --continue --parallel=4 /site/wwwroot $WDIR/wwwroot;
  bye" > /dev/null 2>&1
