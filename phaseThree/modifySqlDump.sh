#!/bin/bash
set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Usage: $0 <old-domain-name>"
  exit 1
fi

HDIR="$HOME/repatriationTask/helperFunctions"
WDIR="$HOME/repatriationTask/_work"

source "$WDIR/urls/old_url.env"
source "$WDIR/urls/new_url.env"

oldUrl="$1"
newUrl="$NEW_URL"

escape_sed_pat() {
  printf '%s' "$1" | sed 's/[][\/$*.^|?+(){}]/\\&/g'
}

escape_sed_repl() {
  printf '%s' "$1" | sed 's/[\/&]/\\&/g'
}

pat=$(escape_sed_pat "$oldUrl")
repl=$(escape_sed_repl "$newUrl")

echo "Replacing $oldUrl with $newUrl in sqldump ..."


sed -i "s|$pat|$repl|g" "$WDIR/dump.sql"

echo -e "URL changed successfully\n"
