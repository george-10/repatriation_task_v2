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


sed -i "s/\(define( 'DB_HOST', *'\)[^']*\(' );\)/\1${DB_HOST_NEW}\2/" $CONFIG_FILE

echo "wp-config.php updated successfully!"
echo "creating zip file"

cd $WDIR/wwwroot
zip -qr "wordpress.zip" *
mv wordpress.zip ./..
cd $DIR
echo "zip success"
