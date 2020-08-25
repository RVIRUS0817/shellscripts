#/bin/bash

DIR=/root/db_backup

DATE=`date +%Y%m%d`
OLD_DATE=`date +%Y%m%d --date "5 days ago"`

DUMP=${DIR}/${DATE}.sql
OLD_DUMP=${DIR}/${OLD_DATE}.sql

pg_dump -h xxx.xx.x.x -U hoge -d redash > ${DUMP}

rm -f ${OLD_DUMP}

### 下記作成する ~/.pgpass
### xxx.xx.xx.xx:5432:redash:hoge:pass
