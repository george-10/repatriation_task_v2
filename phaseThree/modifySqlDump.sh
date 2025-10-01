#!/bin/bash

if [ $# -ne 2 ]; then
  echo "Usage: $0 <old-domain-name> <new-domain-name>"
  exit 1
fi

WDIR="$HOME/repatriationTask/_work"

oldUrl="$1"
newUrl="$2"

echo "Replacing $oldUrl with $newUrl in sqldump ..."


sed -i "s|$oldUrl|$newUrl|g" "$WDIR/dump.sql"

echo -e "URL changed successfully\n"
echo "Changing the string number of the following..."

grep -Ro 's:[0-9]\+:\\"https\?://[^"]\+\\";' "$WDIR/dump.sql"

echo -e "\nChanging...\n"

perl -pi -e 's|s:(\d+):\\\"(https?:\/\/[^\\"]+)\\\";| "s:" . length($2) . ":\\\"$2\\\";" |ge' "$WDIR/dump.sql"

echo "Change done. New urls: "

grep -Ro 's:[0-9]\+:\\"https\?://[^"]\+\\";' "$WDIR/dump.sql"

echo -e "Sql dump modified successfully\n"
