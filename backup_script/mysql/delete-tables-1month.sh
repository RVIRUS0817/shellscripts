#!/bin/sh
MONTH=`date +%s`-2592000
  for OLD_TABLE in `cat tables.list`
  do
    NEW_TABLE="${OLD_TABLE}_new"
    mysql -u root -pxxxxx --database=xxxxx <<eof
    CREATE TABLE $NEW_TABLE LIKE $OLD_TABLE;
    INSERT INTO $NEW_TABLE SELECT * FROM $OLD_TABLE WHERE clock > $MONTH;
    DROP TABLE $OLD_TABLE;
    ALTER TABLE  $NEW_TABLE RENAME $OLD_TABLE;
eof
  done

