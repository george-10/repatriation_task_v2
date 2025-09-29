#!/bin/bash
WDIR="$HOME/repatriationTask/_work"
CONFIG_FILE="$WDIR/wwwroot/wp-config.php"

if [ $# -ne 3 ]; then
    echo "Usage: $0 <username> <password> <host>"
    exit 1
fi

if [[ -f "$WDIR/dump.sql" ]]; then
  echo "SQL dump file already exists. Skipping extraction."
  exit 0
else
  echo "SQL dump file not found. Proceeding with extraction."
fi


user=$1
database=$(grep "define( 'DB_NAME'" "$CONFIG_FILE" | sed "s/.*'DB_NAME', *'\([^']*\)'.*/\1/")
pass=$2
host=$3

echo "Extracting SQL Dump from database $database on host $host with user $user ..."

export MYSQL_PWD="$pass"

mysqldump -h "$host" -u "$user" --databases "$database" > $WDIR/dump.sql

if [ $? -eq 0 ]; then
    echo -e "Import completed successfully \n"
else
    echo -e "Import failed \n"
    exit 1
fi
