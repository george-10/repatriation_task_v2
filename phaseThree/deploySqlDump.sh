#!/bin/bash
HDIR="$HOME/repatriationTask/helperFunctions"
WDIR="$HOME/repatriationTask/_work"

if [ $# -ne 4 ]; then
    echo "Usage: $0 <username> <database-name> <db-password> <host>"
    exit 1
fi

user=$1
database=$2
pass=$3
host=$4

echo "Deploying SQL Dump to database $database on host $host with user $user with password ..."

export MYSQL_PWD="$pass"

mysql -h "$host" -u "$user" "$database" < "$WDIR/dump.sql"

if [ $? -eq 0 ]; then
    printf "Export completed successfully \n"
else
    printf "Export failed \n"
    exit 1
fi
