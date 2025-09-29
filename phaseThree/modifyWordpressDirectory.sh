#!/bin/bash

set -e

WDIR="$HOME/repatriationTask/_work"
DIR="$HOME/repatriationTask/phaseTwo"
CONFIG_FILE="$WDIR/wwwroot/wp-config.php"

source $WDIR/urls/new_url.env
newUrl=$(echo -e '%s\n' "$NEW_URL" | sed 's/&/\\&/g')

if [ $# -ne 2 ]; then
  echo "Usage: $0 <resource-group> <new-domain-name>"
  exit 1
fi

update_wp_config() {
  local key=$1
  local new_value=$2
  local file=$3

  sed -i "s/\(define( '${key}', *'\)[^']*\(' );\)/\1${new_value}\2/" "$file"
}

ResourceGrp=$1
NewDomain=$2

DB_HOST_NEW=$(az mysql flexible-server list \
  --resource-group $ResourceGrp \
  --query "[0].fullyQualifiedDomainName" -o tsv)
echo "Modifying wp-config.php with new DB_HOST: $DB_HOST_NEW ..."


update_wp_config "DB_HOST" "$DB_HOST_NEW" "$CONFIG_FILE"

update_wp_config "DOMAIN_CURRENT_SITE" "$NewDomain" "$CONFIG_FILE"


sed -i "s/\(define( 'DB_HOST', *'\)[^']*\(' );\)/\1${DB_HOST_NEW}\2/" $CONFIG_FILE

echo -e "wp-config.php updated successfully! \n"
echo "creating zip file"

cd $WDIR/wwwroot
zip -qr "wordpress.zip" *
mv wordpress.zip ./..
cd $DIR
echo -e "zip file created successfully \n"
