#!/bin/bash

TABLENAME=$1
COLUMN=$2
CSV=$3
SCRIPT_DIR=$(cd $(dirname $0); pwd)
FILEPATH="${SCRIPT_DIR}/../xxxxxxxxxxxxxxx"

help() {
echo "
  Type:
  (例) ./create-salesforce-config.sh* テーブル名 カラム名 CSV名
    "
}

if [ $# -ne 3 ];then
  help
  exit
fi
### gsedコマンドが入っているか確認 ###
which gsed > /dev/null 2>&1
if [ $? -ne 0 ];then
  echo -e "\ngnuバージョンのsedを使用しているので 'brew install gnu-sed' でコマンドをインストールしてください\n"
  exit
fi

## digdagファイルの作成 ###
cat << EOD > ${FILEPATH}/${TABLENAME}.dig
_error:
  sh>: export \$(cat config/env | xargs) && /digdag/post_slack.sh "[\${session_time}][\${session_id}] DigDag Fail ${TABLENAME}"
+${TABLENAME}:
  sh>: export \$(cat config/env | xargs) && /usr/local/bin/embulk run -b \$EMBULK_BUNDLE_PATH embulk/${TABLENAME}.yml.liquid
EOD
echo ${TABLENAME}.dig done!

# add run.dig
echo -e "\n+$TABLENAME:\n call>: $TABLENAME.dig" >> $FILEPATH/run.dig

### embulkファイルの作成 ###
cat << EOD > ${FILEPATH}/embulk/${TABLENAME}.yml.liquid
in:
  type: salesforce_bulk
  userName: {{ env.SALESFORCE_USER }}
  password: {{ env.SALESFORCE_PASS }}
  authEndpointUrl: {{ env.SALESFORCE_URL }}
  objectType: ${TABLENAME}
  pollingIntervalMillisecond: 5000
  querySelectFrom: |
    SELECT
      ${COLUMN}
    FROM
      ${TABLENAME}
  columns:
EOD

### embulkファイルにcolumnを追加 ###
while read row; do
  column1=$(echo ${row} | cut -d , -f 1)
  echo "  - {type: string, name: ${column1}}"
done < ${CSV} >> $FILEPATH/embulk/${TABLENAME}.yml.liquid

## embulkファイルにoutを追加 ### 
echo "
out:
  type: bigquery
  mode: replace
  auth_method: json_key
  json_keyfile: /digdag/xxxxxxxxxxx/config/bq.key
  {% if env.EMBULK_ENV == 'production' %}
    {% include 'db/prod' %}
  {% else %}
    {% include 'db/pre' %}
  {% endif %}
  auto_create_dataset: true
  auto_create_table: true
  dataset: salesforce
  table: ${TABLENAME}
  schema_file: /digdag/xxxxxxxxxxxx/embulk/db/${TABLENAME}.json
  open_timeout_sec: 300
  send_timeout_sec: 300
  read_timeout_sec: 300
  auto_create_gcs_bucket: false
  gcs_bucket: {{ env.EMBULK_OUTPUT_GCS_BUCKET }}
  compression: GZIP
  source_format: NEWLINE_DELIMITED_JSON
  default_timezone: "Asia/Tokyo"
"  >> $FILEPATH/embulk/${TABLENAME}.yml.liquid

echo ${TABLENAME}.yml.liquid done!

## csvの型をjsonファイルに自動追記 ###
while read row; do
  column1=$(echo ${row} | cut -d , -f 1)
  column2=$(echo ${row} |\
    gsed -E 's/(テキストエリア|テキスト|チェックボックス|選択リスト|電子メール|ルックアップ|電話|通貨|URL).*/String/g'|\
    gsed -E 's/(ID|自動採番|数値|数式).*/INT64/g'|\
    gsed -E 's/日付.*/Timestamp/g'|\
    cut -d , -f 2)
  echo  "    {
        \"name\": \"${column1}\",
        \"type\": \"${column2}\"
    }, "
      
done < ${CSV} > ${FILEPATH}/embulk/db/${TABLENAME}.json

gsed -i -e '1i [' -e '$a ]' ${FILEPATH}/embulk/db/${TABLENAME}.json

### jsonは末尾に,が使えず、embulkでjsonのparseエラーになってしまうので削除する ###
[ -f tmp.json ] && rm -f tmp.json
tail -r ${FILEPATH}/embulk/db/${TABLENAME}.json | gsed '2,1s/,//g' > ${FILEPATH}/embulk/db/${TABLENAME}.json2 \
&& rm -f ${FILEPATH}/embulk/db/${TABLENAME}.json \
&& tail -r ${FILEPATH}/embulk/db/${TABLENAME}.json2 > ${FILEPATH}/embulk/db/${TABLENAME}.json \
&& rm -f ${FILEPATH}/embulk/db/${TABLENAME}.json2
echo ${TABLENAME}.json done!

