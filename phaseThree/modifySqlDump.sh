#!/bin/bash


HDIR="$HOME/repatriationTask/helperFunctions"
WDIR="$HOME/repatriationTask/_work"

source $WDIR/urls/old_url.env
source $WDIR/urls/new_url.env

oldUrl=$(echo -e '%s\n' "$OLD_URL" | sed 's/[.[\*^$/]/\\&/g')

newUrl=$(echo -e '%s\n' "$NEW_URL" | sed 's/&/\\&/g')

echo "Replacing $OLD_URL with $NEW_URL in sqldump ..."

sed -i "s|$oldUrl|$newUrl|g" $WDIR/dump.sql

echo -e "URL changed successfully\n"
