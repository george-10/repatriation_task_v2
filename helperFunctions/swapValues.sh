#!/bin/bash

if [ $# -ne 3 ]; then
  echo "Usage: $0 <old-value> <new-value> <file>";
  exit 1;
fi

old=$1
new=$2
file=$3

sed -i "s|$old|$new|g" $file
