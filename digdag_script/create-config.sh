#!/bin/bash

TABLENAME=$1
COLUMN=$2
SCRIPT_DIR=$(cd $(dirname $0); pwd)
FILEPATH="${SCRIPT_DIR}/../aurora_bigquery"

help() {
echo "
  Type:
  (例) ./create-config.sh テーブル名 カラム名
    "
}

if [ $# -ne 2 ];then
  help
  exit
fi
### Check gsed command
which gsed > /dev/null 2>&1
if [ $? -ne 0 ];then
  echo -e "\ngnuバージョンのsedを使用しているので 'brew install gnu-sed' でコマンドをインストールしてください\n"
  exit
fi

### digdag file ###
cat << EOD > ${FILEPATH}/${TABLENAME}.dig
_error:
  sh>: export \$(cat config/env | xargs) && /opt/redash-ops/digdag/post_chatwork.sh "[\${session_time}][\${session_id}] DigDag Fail ${TABLENAME}"
+${TABLENAME}:
  sh>: export \$(cat config/env | xargs) && /usr/local/bin/embulk run -b \$EMBULK_BUNDLE_PATH embulk/${TABLENAME}.yml.liquid
EOD
echo ${TABLENAME}.dig done!

## add run.dig
echo -e "\n+$TABLENAME:\n  _retry: 3\n  call>: $TABLENAME.dig" >> $FILEPATH/run.dig

### embulk file ###
cat << EOD > ${FILEPATH}/embulk/${TABLENAME}.yml.liquid
in:
  type: mysql
  {% if env.EMBULK_ENV == 'production' %}
    {% include 'db/prod' %}
  {% else %}
    {% include 'db/pre' %}
  {% endif %}
  query: |
    SELECT
      ${COLUMN}
    FROM
      ${TABLENAME}
out:
  type: bigquery
  mode: replace
  auth_method: json_key
  json_keyfile: /bigquery/config/bq.key
  {% if env.EMBULK_ENV == 'production' %}
    {% include 'db/prod_bigquery' %}
  {% else %}
    {% include 'db/pre_bigquery' %}
  {% endif %}
  auto_create_dataset: true
  auto_create_table: true
  dataset: database
  table: ${TABLENAME}
  schema_file: /bigquery/embulk/db/${TABLENAME}.json
  open_timeout_sec: 300
  send_timeout_sec: 300
  read_timeout_sec: 300
  auto_create_gcs_bucket: false
  gcs_bucket: {{ env.EMBULK_OUTPUT_GCS_BUCKET }}
  compression: GZIP
  source_format: NEWLINE_DELIMITED_JSON
  default_timezone: "Asia/Tokyo"
EOD
echo ${TABLENAME}.yml.liquid done!

### embulk JSON file ###
for i in $(echo ${COLUMN} | gsed 's/,/ /g'); do
echo " type: $i" > /dev/null 2>&1
cat << EOD >> ${FILEPATH}/embulk/db/${TABLENAME}.json
    {
        "name": "$i",
        "type": "xxx"
    },
EOD
done

gsed -i -e '1i [' -e '$a ]' ${FILEPATH}/embulk/db/${TABLENAME}.json

### jsonは末尾に,が使えず、embulkでjsonのparseエラーになってしまうので削除する
[ -f tmp.json ] && rm -f tmp.json
tail -r ${FILEPATH}/embulk/db/${TABLENAME}.json | gsed '2,1s/,//g' > ${FILEPATH}/embulk/db/${TABLENAME}.json2 \
&& rm -f ${FILEPATH}/embulk/db/${TABLENAME}.json \
&& tail -r ${FILEPATH}/embulk/db/${TABLENAME}.json2 > ${FILEPATH}/embulk/db/${TABLENAME}.json \
&& rm -f ${FILEPATH}/embulk/db/${TABLENAME}.json2
echo ${TABLENAME}.json done!

echo -e "\n下記の${TABLENAME}.jsonに型を追加してください!!
${COLUMN}
※bool,tinyintはCASTするように!
(例)CAST(name as SIGNED) as name"
