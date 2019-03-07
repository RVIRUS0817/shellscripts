#!/bin/bash
 
DIR=/home/adachin/backup/views/
 
DATE_YEAR=`date +%Y`
DATE=`date +%m%d`
OLD_DATE=`date +%m%d --date "5 days ago"`
 
DATASETS=$(bq  ls --format=sparse | tail -n+3)
 
mkdir -p $DIR/$DATE_YEAR/$DATE
for d in $DATASETS; do
  TABLES=$(bq ls --format=prettyjson "$d" | jq '.[] | "\(.id), \(.type)"')
  IFS=$'\n'
  for table in $TABLES; do
    [[ ! "$table" == *VIEW* ]] && continue
    view=$(echo "$table" | sed -e 's/"//g' | cut -d , -f 1)
    query=$(bq show --format=prettyjson "$view" | jq -r '.view.query')
    echo -e "$query" > "$DIR/$DATE_YEAR/$DATE/$view.sql"
    rm -rf "$DIR/$DATE_YEAR/$OLD_DATE"
  done
done
