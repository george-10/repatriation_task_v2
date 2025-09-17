#!/bin/bash

set -e

WDIR="$HOME/repatriationTask/_work"
DIR="$HOME/repatriationTask/phaseTwo"
CONFIG_FILE="$WDIR/wwwroot/wp-config.php"

if [ $# -ne 3 ]; then
  echo "Usage: $0 <db-user> <db-password> <resource-group>"
  exit 1
fi

DB_USER_NEW=$1
DB_PASSWORD_NEW=$2
ResourceGrp=$3
DB_HOST_NEW=$(az mysql flexible-server list \
  --resource-group $ResourceGrp \
  --query "[0].fullyQualifiedDomainName" -o tsv)


# Update DB_USER
sed -i "s/\(define( 'DB_USER', *'\)[^']*\(' );\)/\1${DB_USER_NEW}\2/" $CONFIG_FILE

# Update DB_PASSWORD
sed -i "s/\(define( 'DB_PASSWORD', *'\)[^']*\(' );\)/\1${DB_PASSWORD_NEW}\2/" $CONFIG_FILE

# Update DB_HOST
sed -i "s/\(define( 'DB_HOST', *'\)[^']*\(' );\)/\1${DB_HOST_NEW}\2/" $CONFIG_FILE

echo "wp-config.php updated successfully!"
echo "creating zip file"

cd $WDIR/wwwroot
zip -qr "wordpress.zip" *
mv wordpress.zip ./..
cd $DIR
echo "zip success"
