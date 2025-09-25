#!/bin/bash

WDIR="$HOME/repatriationTask/_work"

if [ $# -ne 2 ]; then
  echo "Usage: $0 <resource-group> <app-service-name>"
  exit 1
fi

rgName=$1
appName=$2

if [[ -f "$WDIR/wwwrootzip.zip" && -d "$WDIR/wwwroot"]]; then
  echo "Root zip file and wwwroot directory already exist. Skipping extraction."
  exit 0
else
  echo "Root zip file or wwwroot directory not found. Proceeding with extraction."
fi

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

echo "Extracting wwwroot from App Service: $appName ..."

mkdir -p "$WDIR/urls"
[ -f $WDIR/urls/old_url.env ] && rm $WDIR/urls/old_url.env


appUrl=$(az webapp show \
  --name "$appName" \
  --resource-group "$rgName" \
  --query "defaultHostName" \
  -o tsv)

scm_url=$(echo "$appUrl" | awk -F'.' '{print $1 ".scm." $2 "." $3 "." $4}')
scm_url="https://$scm_url/api/zip/site/wwwroot/"


echo "export OLD_URL=${appUrl}" > $WDIR/urls/old_url.env

echo "OLD_URL set to ${appUrl}"

echo "Connecting to App Service: $appName"
echo "URL: $scm_url"
echo "User: $appName"
echo "Password: $password"

cred="\$$appName:$password"
echo "Credentials: $cred"

curl -u "$cred" -o $WDIR/wwwrootzip.zip $scm_url

echo "Unzipping the wwwroot: "

unzip $WDIR/wwwrootzip.zip -d $WDIR/wwwroot

echo -e "Unzipping completed. Files are in $WDIR/wwwroot\n"
