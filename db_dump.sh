# /bin/sh

DUMP=/db/mysqldump.`date +\%Y-\%m-\%d`.sql
OLD_FILE=$DUMP.`date +\%Y-\%m-\%d --date "-1 days"`.sql
LOG=mysql-`date +\%Y-\%m-\%d --date "-1 days"`.log

mysqldump -h clientIP -u root -x -ppassword --all-databases > $DUMP
mysql -h MyDBIP -u root -ppassword < $DUMP
rm -rf $OLD_FILE $LOG
