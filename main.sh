#!/bin/bash
DIR="$HOME/repatriationTask"
INPUTS="$HOME/repatriationTask/inputs.json"
count=$(jq length "$INPUTS")

cd "$DIR"

for i in $(seq 0 $((count-1))); do
  mkdir -p ./_work
  jq ".[$i]" "$INPUTS" > "input.json"
  echo "Created input.json for the iteration number $i"

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
  echo "Extracted values for iteration $i:"
  echo "  oldSubscriptionName: $oldSubscriptionName"
  echo "  oldResourceGroup: $oldResourceGroup"
  echo "  oldAppServiceName: $oldAppServiceName"
  echo "  oldSqlServerName: $oldSqlServerName"
  echo "  newSubscriptionName: $newSubscriptionName"
  echo "  newResourceGroup: $newResourceGroup"
  echo "  newAppServiceName: $newAppServiceName"
  echo "  newSqlServerName: $newSqlServerName"
  echo "  newAppServiceSubnet: $newAppServiceSubnet"
  echo "  dbPassword: $dbPassword"

  cd ./phaseOne
  ./mainPhaseOne.sh $oldResourceGroup $oldAppServiceName $oldSqlServerName $dbPassword
  cd $DIR

  cp ./input.json ./phaseTwo
  cd ./phaseTwo
  ./mainPhaseTwo.sh
  cd $DIR

  cd ./phaseThree
  ./mainPhaseThree.sh $newResourceGroup $newSqlServerName $dbPassword
  cd $DIR
  
  rm -rf ./_work
done

cd "$HOME"
