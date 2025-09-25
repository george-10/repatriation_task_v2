#!/bin/bash

set -e

DIR="$HOME/repatriationTask"
INPUTS="$HOME/repatriationTask/inputs.json"
count=$(jq length "$INPUTS")

cd "$DIR"

confirm_if_required() {
  local confirm
  confirm=$(jq -r '.waitForUserConfirmation' config.json)
  if [ "$confirm" = "true" ]; then
    read -p "Do you want to continue? (y/n): " answer
    if [ "$answer" != "y" ]; then
      echo "Process aborted by user."
      exit 1
    fi
  fi
}

for i in $(seq 0 $((count-1))); do
  mkdir -p ./_work
  jq ".[$i]" "$INPUTS" > "input.json"
  echo "-----------------------------------------------------------------"
  echo "Starting iteration $i"
  printf "-----------------------------------------------------------------\n"
  echo "Input file created for iteration $i."

  oldSubscriptionName=$(jq -r '.oldSubscriptionName' input.json)
  oldResourceGroup=$(jq -r '.oldResourceGroup' input.json)
  newSubscriptionName=$(jq -r '.newSubscriptionName' input.json)
  newResourceGroup=$(jq -r '.newResourceGroup' input.json)
  newAppServiceName=$(jq -r '.newAppServiceName' input.json)
  newSqlServerName=$(jq -r '.newSqlServerName' input.json)
  newAppServiceSubnet=$(jq -r '.newAppServiceSubnet' input.json)
  #Key Vault to get old DB password and old User name
  keyVaultName=$(jq -r '.keyVaultName' input.json)
  secretName=$(jq -r '.secretName' input.json)
  oldDbPassword=$(az keyvault secret show --vault-name $keyVaultName --name $secretName --query value -o tsv)
  oldUserName=$(echo $(az keyvault secret show --vault-name $keyVaultName --name $secretName --query "contentType") | tr -d '"')
  newDbPassword=$(jq -r '.newDbPassword' input.json)


  if jq -e 'has("oldAppServiceName")' input.json > /dev/null; then
    oldAppServiceName=$(jq -r '.oldAppServiceName' input.json)
  else
    echo "Old App Service name not found in input.json. Fetching with helper script..."
    oldAppServiceName=$($DIR/helperFunctions/getAppServiceName.sh "$oldResourceGroup")
  fi

  if jq -e 'has("oldSqlServerName")' input.json > /dev/null; then
    oldSqlServerName=$(jq -r '.oldSqlServerName' input.json)
  else
    echo "Old SQL Server name not found in input.json. Fetching with helper script..."
    oldSqlServerName=$($DIR/helperFunctions/getSqlServerName.sh "$oldResourceGroup")
  fi

  echo "Configuration for iteration $i:"
  echo "  Old Subscription:   $oldSubscriptionName"
  echo "  Old Resource Group: $oldResourceGroup"
  echo "  Old App Service:    $oldAppServiceName"
  echo "  Old SQL Server:     $oldSqlServerName"
  echo "  New Subscription:   $newSubscriptionName"
  echo "  New Resource Group: $newResourceGroup"
  echo "  New App Service:    ${newAppServiceName}-APP01"
  echo "  New SQL Server:     $newSqlServerName"
  echo "  New App Service Subnet: $newAppServiceSubnet"
  echo "  Old User Name for sql dump: $oldUserName"

  echo " "
#  echo "  Database Password:  $dbPassword"

  echo "Setting subscription to $oldSubscriptionName ..."
  az account set --subscription "$oldSubscriptionName"
  printf "Subscription set to $oldSubscriptionName \n"

  cd ./phaseOne
  ./mainPhaseOne.sh $oldResourceGroup $oldAppServiceName $oldSqlServerName $oldDbPassword $oldUserName
  cd $DIR
  confirm_if_required

  echo "Setting subscription to $newSubscriptionName ..." 
  az account set --subscription "$newSubscriptionName"
  printf "Subscription set to $newSubscriptionName \n"

  cp ./input.json ./phaseTwo
  cd ./phaseTwo
  ./mainPhaseTwo.sh $newDbPassword
  cd $DIR
  confirm_if_required

  printf "\n"
  cd ./phaseThree
  ./mainPhaseThree.sh $newResourceGroup $newSqlServerName $newDbPassword
  cd $DIR
  confirm_if_required

  echo "Cleaning up ..."
  rm ./input.json
  rm -rf ./_work
  echo "_work deleted. input.json for iteration $i deleted."
  printf "Cleanup completed.\n"
  echo "-----------------------------------------------------------------"
  echo "Iteration $i completed."
  printf "-----------------------------------------------------------------\n"
done

cd "$HOME"
