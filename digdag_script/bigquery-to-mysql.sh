#!/bin/bash

YESTERDAY=$(date +%Y-%m-%d -d '1 days ago')
DBPass=xxxxxxxxxx

## out csv
bq query --use_legacy_sql=false --format=csv --max_rows=100000 "SELECT * FROM \`prd-adachin.views.views\` where dt=\"${YESTERDAY}\"" > views.csv

## add ,
sed -i '1,2d' views.csv
sed -i "s/^/,/g" views.csv

# restore
mysql -h xxxxxxxxxx -u xxxxxxx -p${DBPass} -P xxxxxx adachin -N -e "LOAD DATA LOCAL INFILE '/home/views.csv' INTO TABLE daily_views FIELDS TERMINATED BY ','"

## delete views.csv
rm -rf views.csv
