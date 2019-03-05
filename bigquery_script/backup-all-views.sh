#!/bin/bash

DATE=`date +%Y%m%d`
OLD_DATE=`date +%Y%m%d --date "5 days ago"`

DATASETS=$(bq  ls --format=sparse | tail -n+3)
for d in $DATASETS; do
  TABLES=$(bq ls --format=prettyjson "$d" | jq '.[] | "\(.id), \(.type)"')
  IFS=$'\n'
  for table in $TABLES; do
    [[ ! "$table" == *VIEW* ]] && continue
    view=$(echo "$table" | sed -e 's/"//g' | cut -d , -f 1)
    query=$(bq show --format=prettyjson "$view" | jq -r '.view.query')
    echo -e "$query" > "/home/adachin/backup/views/$view.sql.$DATE"
    rm -rf "/home/adachin/backup/views/$view.sql.$OLD_DATE"
  done
done
