#!/bin/bash

$(".common/secrets.sh")
YESTERDAY=$(date +%Y-%m-%d -d '1 days ago')

## views out csv
/home/adachin/google-cloud-sdk/bin/bq query --use_legacy_sql=false --format=csv --max_rows=100000 "SELECT * FROM \`prd-adachin.views.views\` where dt=\"${YESTERDAY}\"" > /tmp/views.csv

## add ,
sed -i '1,2d' /tmp/views.csv
sed -i "s/^/,/g" /tmp/views.csv

# restore
mysql -h "${HOST}" -u adachin -p"${PWD}" -P "${PORT}" adachin -N -e "LOAD DATA LOCAL INFILE '/tmp/views.csv' INTO TABLE views FIELDS TERMINATED BY ','"

## rm profile_views.
rm -f /tmp/views.csv
