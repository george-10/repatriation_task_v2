#!/bin/bash
set -euo pipefail

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
