#!/bin/bash


HDIR="$HOME/repatriationTask/helperFunctions"
WDIR="$HOME/repatriationTask/_work"

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <resource-group>"
    exit 1
fi


RESOURCE_GROUP=$1
APP_NAME=$(az webapp list \
  --resource-group $RESOURCE_GROUP \
  --query "[0].name" -o tsv)

username=$(az webapp deployment list-publishing-profiles \
  --name "$APP_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --query "[?publishMethod=='FTP'].[userName]" \
  -o tsv)

password=$(az webapp deployment list-publishing-profiles \
  --name "$APP_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --query "[?publishMethod=='FTP'].[userPWD]" \
  -o tsv| head -1)


appUrl=$(az webapp show \
  --name "$APP_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --query "defaultHostName" \
  -o tsv)

scm_url_base=$(awk -F. 'BEGIN{OFS="."} {$1=$1 ".scm"; print}' <<< "$appUrl")
scm_url_root="https://$scm_url_base/api/zipdeploy"
scm_url_default="https://$scm_url_base/api/vfs/default"
echo "Deploying wordpress.zip to App Service '$APP_NAME' in resource group '$RESOURCE_GROUP'..."

cred="\$$APP_NAME:$password"
echo "Credentials: $cred"

echo "Deploying default file to App Service '$APP_NAME' in resource group '$RESOURCE_GROUP'..."
curl -X PUT -u "$cred" \
  --data-binary @"$WDIR/default" \
  "$scm_url_default"
echo -e "\nDefault file deployment complete.\n"
echo -e "Deploying wordpress.zip to App Service '$APP_NAME' in resource group '$RESOURCE_GROUP'...\n"

az webapp deployment source config-zip \
    --resource-group "$RESOURCE_GROUP" \
    --name "$APP_NAME" \
    --src $WDIR/wordpress.zip \
    --timeout 7200

echo "Zip file deployment complete."



if [ $? -eq 0 ]; then
    echo -e "Deployment succeeded\n"
else
    echo -e "Deployment failed\n"
    exit 1
fi
