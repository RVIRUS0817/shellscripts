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
