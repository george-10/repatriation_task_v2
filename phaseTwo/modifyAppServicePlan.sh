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

$HDIR/swapValues.sh "$oldRegion" "$newRegion" $WDIR/resources_template/$oldName.json
$HDIR/swapValues.sh "$oldName" "$newName" $WDIR/resources_template/$oldName.json

echo "Modified $WDIR/resources_template/$oldName.json"