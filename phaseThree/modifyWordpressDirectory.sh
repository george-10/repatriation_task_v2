#!/bin/bash
set -euo pipefail

WDIR="$HOME/repatriationTask/_work"
DIR="$HOME/repatriationTask/phaseTwo"
CONFIG_FILE="$WDIR/wwwroot/wp-config.php"

source "$WDIR/urls/new_url.env"

if [ $# -ne 1 ]; then
  echo "Usage: $0 <resource-group>"
  exit 1
fi

escape_sed_repl() {
  printf '%s' "$1" | sed 's/[\\&/]/\\&/g'
}

sed_inplace() {
  local script=$1
  local file=$2
  local tmp
  tmp="$(mktemp "${file##*/}.XXXXXX")"
  sed -e "$script" -- "$file" >"$tmp"
  mv -- "$tmp" "$file"
}

update_wp_config() {
  local key=$1
  local value=$2
  local file=$3

  local repl
  repl=$(escape_sed_repl "$value")


  local d=$'\x1f'
  local script="s${d}\\(define([[:space:]]*[\"']${key}[\"'][[:space:]]*,[[:space:]]*['\"]\\)[^'\"]*\\(['\"][[:space:]]*\\)${d}\\1${repl}\\2${d}"

  sed_inplace "$script" "$file"
}

ResourceGrp=$1

# Get new DB host from Azure
DB_HOST_NEW="$(az mysql flexible-server list \
  --resource-group "$ResourceGrp" \
  --query "[0].fullyQualifiedDomainName" -o tsv)"

echo "Modifying wp-config.php with new DB_HOST: $DB_HOST_NEW ..."

update_wp_config "DB_HOST" "$DB_HOST_NEW" "$CONFIG_FILE"
update_wp_config "DOMAIN_CURRENT_SITE" "$NEW_URL" "$CONFIG_FILE"

echo -e "wp-config.php updated successfully! \n"
echo "creating zip file"

cd "$WDIR/wwwroot"
zip -qr "wordpress.zip" *
mv wordpress.zip ./..
cd "$DIR"
echo -e "zip file created successfully \n"
