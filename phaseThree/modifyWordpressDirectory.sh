#!/bin/bash

set -e

WDIR="$HOME/repatriationTask/_work"
DIR="$HOME/repatriationTask/phaseTwo"
CONFIG_FILE="$WDIR/wwwroot/wp-config.php"

source $WDIR/urls/new_url.env
newUrl=$(echo -e '%s\n' "$NEW_URL" | sed 's/&/\\&/g')

if [ $# -ne 1 ]; then
  echo "Usage: $0 <resource-group>"
  exit 1
fi

escape_sed_repl() {
  printf '%s' "$1" | sed 's/[\/&]/\\&/g'
}

update_wp_config() {
  local key=$1
  local new_value=$2
  local file=$3

  local repl
  repl=$(escape_sed_repl "$new_value")

  sed -i "s|\(define( '${key}', *'\)[^']*\(' );\)|\1${repl}\2|" "$file"
}

source $WDIR/urls/new_url.env

ResourceGrp=$1
NewDomain=$(echo -e '%s\n' "$NEW_URL" | sed 's/&/\\&/g')


DB_HOST_NEW=$(az mysql flexible-server list \
  --resource-group $ResourceGrp \
  --query "[0].fullyQualifiedDomainName" -o tsv)
echo "Modifying wp-config.php with new DB_HOST: $DB_HOST_NEW ..."


update_wp_config "DB_HOST" "$DB_HOST_NEW" "$CONFIG_FILE"

update_wp_config "DOMAIN_CURRENT_SITE" "$NewDomain" "$CONFIG_FILE"


echo -e "wp-config.php updated successfully! \n"
echo "creating zip file"

cd $WDIR/wwwroot
zip -qr "wordpress.zip" *
mv wordpress.zip ./..
cd $DIR
echo -e "zip file created successfully \n"
