# /bin/sh

DUMP=/db/mysqldump.`date +\%Y-\%m-\%d`.sql
OLD_FILE=$DUMP.`date +\%Y-\%m-\%d --date "-1 days"`.sql
LOG=mysql-`date +\%Y-\%m-\%d --date "-1 days"`.log

mysqldump -h clientIP -u root -x -ppassword --all-databases > $DUMP
mysql -h MyDBIP -u root -ppassword < $DUMP
rm -rf $OLD_FILE $LOG

---------------or

# /bin/sh

OUTPUTDIR="/home/adachin/db_back"
for x in hogedb; do

  FILE=$OUTPUTDIR/$x.`date +\%Y-\%m-\%d`.sql.gz
  OLD_FILE=$OUTPUTDIR/$x.`date +\%Y-\%m-\%d --date "-30 days"`.sql.gz
  mysqldump -h localhost -u root $x | gzip > ${FILE}

  rm -f ${OLD_FILE}
done

-----or

# /bin/sh

DUMP=/home/adachin/db_back/db-`date +\%Y-\%m-\%d`.sql

mysqldump -h localhost -u root $x | gzip > ${FILE}

-
crontab -l
00 04 * * * find /db-* -mtime +7 -exec rm -f {} \;

