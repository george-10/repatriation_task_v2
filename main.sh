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
  echo -e "-----------------------------------------------------------------\n"
  echo "Input file created for iteration $i."

  oldSubscriptionName=$(jq -r '.oldSubscriptionName' input.json)
  oldResourceGroup=$(jq -r '.oldResourceGroup' input.json)
  newSubscriptionName=$(jq -r '.newSubscriptionName' input.json)
  newResourceGroup=$(jq -r '.newResourceGroup' input.json)
  newAppServiceName=$(jq -r '.newAppServiceName' input.json)
  newSqlServerName=$(jq -r '.newSqlServerName' input.json)
  newAppServiceSubnet=$(jq -r '.newAppServiceSubnet' input.json)
  keyVaultName=$(jq -r '.keyVaultName' input.json)
  secretName=$(jq -r '.secretName' input.json)
  dbPassword=$(az keyvault secret show --vault-name $keyVaultName --name $secretName --query value -o tsv)

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
#  echo "  Database Password:  $dbPassword"

  echo "Setting subscription to $oldSubscriptionName ..."
  az account set --subscription "$oldSubscriptionName"
  echo "Subscription set to $oldSubscriptionName \n"

  cd ./phaseOne
  ./mainPhaseOne.sh $oldResourceGroup $oldAppServiceName $oldSqlServerName $dbPassword
  cd $DIR
  confirm_if_required

  echo "Setting subscription to $newSubscriptionName ..." 
  az account set --subscription "$newSubscriptionName"
  echo -e "Subscription set to $newSubscriptionName \n"

  cp ./input.json ./phaseTwo
  cd ./phaseTwo
  ./mainPhaseTwo.sh
  cd $DIR
  confirm_if_required

  echo -e "\n"
  cd ./phaseThree
  ./mainPhaseThree.sh $newResourceGroup $newSqlServerName $dbPassword
  cd $DIR
  confirm_if_required

  echo "Cleaning up ..."
  rm ./input.json
  rm -rf ./_work
  echo -e "Cleanup completed.\n"
  echo "-----------------------------------------------------------------"
  echo "Iteration $i completed."
  echo -e"-----------------------------------------------------------------\n"
done

cd "$HOME"
