#!/bin/bash
WDIR="$HOME/repatriationTask/_work"
if [ $# -ne 4 ]; then
    echo "Usage: $0 <username> <database-name> <password> <host>"
    exit 1
fi

user=$1
database=$2
pass=$3
host=$4

export MYSQL_PWD="$pass"

mysqldump -h "$host" -u "$user" --databases "$database" > $WDIR/dump.sql

if [ $? -eq 0 ]; then
    echo "Import completed successfully"
else
    echo "Import failed"
    exit 1
fi
