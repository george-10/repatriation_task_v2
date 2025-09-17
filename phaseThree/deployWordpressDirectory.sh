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


if [ ! -f "wordpress.zip" ]; then
    echo "Error: wordpress.zip not found in current directory."
    exit 1
fi

echo "Deploying wordpress.zip to App Service '$APP_NAME' in resource group '$RESOURCE_GROUP'..."
az webapp deploy \
    --resource-group "$RESOURCE_GROUP" \
    --name "$APP_NAME" \
    --src-path $WDIR/wordpress.zip \
    --type zip

if [ $? -eq 0 ]; then
    echo "Deployment succeeded"
else
    echo "Deployment failed"
    exit 1
fi
