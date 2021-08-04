#/bin/bash

# vim ~/.common/secrets.sh
#echo readonly USER='hoge'
#echo readonly PWD='hoge'
#echo readonly HOST='hoge'

set -eu

$("~/.common/secrets.sh")

DIR=/root/backup
DATE=`date +%Y%m%d`
OLD_DATE=`date +%Y%m%d --date "5 days ago"`
DUMP=${DIR}/mysqldump.${DATE}.sql
OLD_DUMP=${DIR}/mysqldump.${OLD_DATE}.sql

mysqldump -v --skip-column-statistics --skip-lock-tables -h "${HOST}" -u "${USER}" -p"${PWD}" hoge_db | gzip > ${DUMP}

rm -f ${OLD_DUMP}
