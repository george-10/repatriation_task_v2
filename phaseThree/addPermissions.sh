#!/bin/bash
set -euo pipefail

WDIR="$HOME/repatriationTask/_work"
HDIR="$HOME/repatriationTask/helperFunctions"
CONFIG_FILE="$WDIR/wwwroot/wp-config.php"

if [ $# -ne 2 ]; then
  echo "Usage: $0 <db-root-user> <db-root-pass>"
  exit 1
fi

DB_HOST=$(grep "DB_HOST" "$CONFIG_FILE" | sed "s/.*'DB_HOST', *'\([^']*\)'.*/\1/")
DB_ROOT_USER=$1
DB_ROOT_PASS=$2

DB_NAME=$(grep "DB_NAME" "$CONFIG_FILE" | sed "s/.*'DB_NAME', *'\([^']*\)'.*/\1/")
DB_USER=$(grep "DB_USER" "$CONFIG_FILE" | sed "s/.*'DB_USER', *'\([^']*\)'.*/\1/")
DB_PASS=$(grep "DB_PASSWORD" "$CONFIG_FILE" | sed "s/.*'DB_PASSWORD', *'\([^']*\)'.*/\1/")

echo "Adding database user '$DB_USER' with access to database '$DB_NAME' on host '$DB_HOST' ..."

mysql -h"$DB_HOST" -u"$DB_ROOT_USER" --password="$DB_ROOT_PASS" <<EOF
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF

mysql -h"$DB_HOST" -u"$DB_ROOT_USER" --password="$DB_ROOT_PASS" -e \
"SHOW GRANTS FOR '${DB_USER}'@'%';"

echo -e "User '$DB_USER' added successfully with access to database '$DB_NAME' on host '$DB_HOST' \n"
