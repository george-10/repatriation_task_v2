#!/bin/bash

HDIR="$HOME/repatriationTask/helperFunctions"
WDIR="$HOME/repatriationTask/_work"

if [ $# -ne 4 ]; then
  echo "Usage: $0 <old-region> <new-region> <old-name> <new-name>"
  exit 1
fi

oldRegion=$1
newRegion=$2
oldName=$3
newName=$4

echo "Modifying App Service Plan template $oldName.json ..."
echo "Old Region: $oldRegion"
echo "New Region: $newRegion"
echo "Old Name: $oldName"
echo "New Name: $newName"

$HDIR/swapValues.sh "$oldRegion" "$newRegion" $WDIR/resources_template/$oldName.json
$HDIR/swapValues.sh "$oldName" "$newName" $WDIR/resources_template/$oldName.json

echo -e "Modification complete.\n"