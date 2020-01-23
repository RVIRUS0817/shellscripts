#/bin/bash

DIR=/root/mount-s3/backup

DATE=`date +%Y%m%d`
OLD_DATE=`date +%Y%m%d --date "5 days ago"`

DUMP=${DIR}/mysqldump.${DATE}.sql
OLD_DUMP=${DIR}/mysqldump.${OLD_DATE}.sql

mysqldump -u root -pxxxx --all-databases > ${DUMP}

rm -f ${OLD_DUMP}
