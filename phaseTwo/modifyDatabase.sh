#!/bin/bash


HDIR="$HOME/repatriationTask/helperFunctions"
WDIR="$HOME/repatriationTask/_work"

oldRegion=$1
newRegion=$2
oldName=$3
newName=$4
dbPassword=$5

echo "Modifying Database template $oldName.json ..."
echo "Old Region: $oldRegion"
echo "New Region: $newRegion"
echo "Old Name: $oldName"
echo "New Name: $newName"
echo "DB Password: [HIDDEN]"

$HDIR/swapValues.sh "$oldRegion" "$newRegion" $WDIR/resources_template/$oldName.json
$HDIR/swapValues.sh "$oldName" "$newName" $WDIR/resources_template/$oldName.json

jq --arg pass "$dbPassword" \
  '(.resources[] | select(.type == "Microsoft.DBforMySQL/flexibleServers").properties.administratorLoginPassword) = $pass' \
  $WDIR/resources_template/$oldName.json > tmp.json && mv tmp.json $WDIR/resources_template/$oldName.json


jq '.resources |= map(select(.type != "Microsoft.DBforMySQL/flexibleServers/backups"))' \
   $WDIR/resources_template/$oldName.json > tmp.json && mv tmp.json $WDIR/resources_template/$oldName.json

jq '.resources |= map(select(.type != "Microsoft.DBforMySQL/flexibleServers/backupsv2"))' \
   $WDIR/resources_template/$oldName.json > tmp.json && mv tmp.json $WDIR/resources_template/$oldName.json

jq '.resources |= map(select(.type != "Microsoft.DBforMySQL/flexibleServers/configurations"
                             or (.name != "$newDatabase/slow_query_log_file"
                                 and .name != "$newDatabase/general_log_file")))' \
   $WDIR/resources_template/$oldName.json > tmp.json && mv tmp.json $WDIR/resources_template/$oldName.json


jq '(.resources[]
      | select(.type=="Microsoft.DBforMySQL/flexibleServers").properties) 
      |= del(.maintenancePolicy, .maintenanceWindow)' \
   $WDIR/resources_template/$oldName.json > tmp.json && mv tmp.json $WDIR/resources_template/$oldName.json


jq '.resources |= map(
      select(
        .type != "Microsoft.DBforMySQL/flexibleServers/databases"
        or (.name | (endswith("/information_schema")
                     or endswith("/mysql")
                     or endswith("/performance_schema")
                     or endswith("/sys")) | not)
      )
    )' $WDIR/resources_template/$oldName.json > tmp.json && mv tmp.json $WDIR/resources_template/$oldName.json

jq '.resources |= map(
      select(
        .type != "Microsoft.DBforMySQL/flexibleServers/configurations"
        or (.properties.source // "") != "system-default"
      )
    )' $WDIR/resources_template/$oldName.json > tmp.json && mv tmp.json $WDIR/resources_template/$oldName.json

jq --arg db "$newName" \
  'del(.resources[] | select(.type=="Microsoft.DBforMySQL/flexibleServers/configurations"
                             and .name==($db + "/general_log_file")))' \
  $WDIR/resources_template/$oldName.json > tmp.json && mv tmp.json $WDIR/resources_template/$oldName.json

jq --arg db "$newName" \
  'del(.resources[] | select(.type=="Microsoft.DBforMySQL/flexibleServers/configurations"
                             and .name==($db + "/log_bin")))' \
  $WDIR/resources_template/$oldName.json > tmp.json && mv tmp.json $WDIR/resources_template/$oldName.json

jq --arg db "$newName" \
  'del(.resources[] | select(.type=="Microsoft.DBforMySQL/flexibleServers/configurations"
                             and .name==($db + "/server_id")))' \
  $WDIR/resources_template/$oldName.json > tmp.json && mv tmp.json $WDIR/resources_template/$oldName.json

jq --arg db "$newName" \
  'del(.resources[] | select(.type=="Microsoft.DBforMySQL/flexibleServers/configurations"
                             and .name==($db + "/slow_query_log_file")))' \
  $WDIR/resources_template/$oldName.json > tmp.json && mv tmp.json $WDIR/resources_template/$oldName.json

jq '(.resources[] 
    | select(.type=="Microsoft.DBforMySQL/flexibleServers") 
    | .properties) |= del(.databasePort)' \
"$WDIR/resources_template/$oldName.json" > tmp.json && mv tmp.json "$WDIR/resources_template/$oldName.json"

echo -e "Modification complete.\n"