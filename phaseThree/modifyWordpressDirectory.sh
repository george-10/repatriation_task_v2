#!/bin/bash

set -e

WDIR="$HOME/repatriationTask/_work"
DIR="$HOME/repatriationTask/phaseTwo"
CONFIG_FILE="$WDIR/wwwroot/wp-config.php"

if [ $# -ne 1 ]; then
  echo "Usage: $0 <resource-group>"
  exit 1
fi


ResourceGrp=$1
DB_HOST_NEW=$(az mysql flexible-server list \
  --resource-group $ResourceGrp \
  --query "[0].fullyQualifiedDomainName" -o tsv)
echo "Modifying wp-config.php with new DB_HOST: $DB_HOST_NEW ..."

sed -i "s/\(define( 'DB_HOST', *'\)[^']*\(' );\)/\1${DB_HOST_NEW}\2/" $CONFIG_FILE

printf "wp-config.php updated successfully! \n"
echo "creating zip file"

cd $WDIR/wwwroot
zip -qr "wordpress.zip" *
mv wordpress.zip ./..
cd $DIR
printf "zip file created successfully \n"
