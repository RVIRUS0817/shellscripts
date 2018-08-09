#!/bin/bash

set -e

help()
{
echo "
  Type:
  (例) ./create-config.sh テーブル名 カラム名
    "
}

if [ $# -ne 2 ];then
  help
  exit
fi

TABLENAME=$1
COLUMN=$2

### digdag file ###
cat << EOD > ../bigquery/$TABLENAME.dig
_error:
  sh>: export \$(cat config/env | xargs) && /opt/redash-ops/digdag/post_chatwork.sh "[\${session_time}][\${session_id}] DigDag Fail $TABLENAME"

+$TABLENAME:
  sh>: export \$(cat config/env | xargs) && /usr/local/bin/embulk run -b \$EMBULK_BUNDLE_PATH embulk/$TABLENAME.yml.liquid
EOD
echo $TABLENAME.dig done!

### embulk file ###
cat << EOD > ../bigquery/embulk/$TABLENAME.yml.liquid
in:
  type: mysql
  {% if env.EMBULK_ENV == 'production' %}
    {% include 'db/prod_ljp' %}
  {% else %}
    {% include 'db/pre_ljp' %}
  {% endif %}
  query: |
    SELECT
      $COLUMN
    FROM
      $TABLENAME
out:
  type: bigquery
  mode: replace
  auth_method: json_key
  json_keyfile: /digdag/bigquery/config/bq.key
  {% if env.EMBULK_ENV == 'production' %}
    {% include 'db/prod_bigquery' %}
  {% else %}
    {% include 'db/pre_bigquery' %}
  {% endif %}
  auto_create_dataset: true
  auto_create_table: true
  dataset: ljp_database
  table: $TABLENAME
  schema_file: /digdag/bigquery/embulk/db/$TABLENAME.json
  open_timeout_sec: 300
  send_timeout_sec: 300
  read_timeout_sec: 300
  auto_create_gcs_bucket: false
  gcs_bucket: {{ env.EMBULK_OUTPUT_GCS_BUCKET }}
  compression: GZIP
  source_format: NEWLINE_DELIMITED_JSON
  default_timezone: "Asia/Tokyo"
EOD
echo $TABLENAME.yml.liquid done!

### embulk JSON file ###
COLUMN2=$(echo $COLUMN | gsed 's/,/ /g')
echo "[" > ../bigquery/embulk/db/$TABLENAME.json
for i in $(echo $COLUMN2);
  do echo " type: $i" > /dev/null 2>&1
cat << EOD >> ../bigquery/embulk/db/$TABLENAME.json
    {
        "name": "$i",
        "type": "xxx"
    },
EOD
done
echo "]" >> ../bigquery/embulk/db/$TABLENAME.json
tail -r ../bigquery/embulk/db/$TABLENAME.json | gsed '2,1s/,//g' > ../bigquery/embulk/db/$TABLENAME.json2 && rm -f ../bigquery/embulk/db/$TABLENAME.json && tail -r ../bigquery/embulk/db/$TABLENAME.json2 > ../_bigquery/embulk/db/$TABLENAME.json && rm -f ../bigquery/embulk/db/$TABLENAME.json2
echo $TABLENAME.json done!

echo -e "\n下記のカラムを$TABLENAME.jsonに追加してください!!
$COLUMN
※bool,tinyintはCASTするように!
(例)CAST(name as SIGNED) as name"
