#!/bin/bash

S3=$1
TABLENAME=$2
COLUMN=$3
SCRIPT_DIR=$(cd $(dirname $0); pwd)
FILEPATH="${SCRIPT_DIR}/../s3_to_bigquery"

help() {
echo "
  Type:
  (例) ./s3create-config.sh S3ディレクトリ名 テーブル名 カラム名(カンマ区切り)
  (例) ./s3create-config.sh test/test_session test_test_session id,user_id
    "
}

if [ $# -ne 3 ];then
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
_export:
  s3_target_date: \${moment(session_date).subtract(1,'days').format('YYYY-MM-DD')}
  bq_target_date: \${moment(session_date).subtract(1,'days').format('YYYYMMDD')}
_error:
  sh>: export \$(cat config/env | xargs) && /opt/redash-ops/digdag/post_chatwork.sh "[\${session_time}][\${session_id}] DigDag Fail ${TABLENAME}"
+load:
  sh>: export \$(cat config/env | xargs) && /usr/local/bin/embulk run -b \$EMBULK_BUNDLE_PATH embulk/${TABLENAME}.yml.liquid
EOD
echo ${TABLENAME}.dig done!

## add run.dig
echo -e "\n+$TABLENAME:\n  _retry: 3\n  call>: $TABLENAME.dig" >> $FILEPATH/run.dig

### embulk file ###
cat << EOD > ${FILEPATH}/embulk/${TABLENAME}.yml.liquid
in:
  type: s3
  path_prefix: lancers/activity/$S3/dt={{ env.s3_target_date }}/
  bucket: {{ env.EMBULK_INPUT_S3_BUCKET }}
  access_key_id: {{ env.AWS_ACCESS_KEY }}
  secret_access_key: {{ env.AWS_SECRET_KEY }}
  decoders:
  - {type: gzip}
  parser:
    type: jsonl
    charset: UTF-8
    newline: CRLF
    columns:
    - {name: "time", type: "timestamp", format: "%Y-%m-%dT%H:%M:%S%z"}
filters:
  - type: add_time
    to_column:
      name: time_jst
      type: timestamp
    from_column:
      name: time
  - type: eval
    eval_columns:
      - time_jst: value + (9 * 60 * 60)
  - type: to_json
    column: {name: time, type: string}
    default_format: "%Y-%m-%d %H:%M:%S"
out:
  type: bigquery
  mode: replace
  payload_column: time
  auth_method: json_key
  json_keyfile: /digdag/ljp_s3_to_bigquery/config/bq.key
  {% if env.EMBULK_ENV == 'production' %}
    {% include 'db/prod' %}
  {% else %}
    {% include 'db/pre' %}
  {% endif %}
  auto_create_dataset: true
  auto_create_table: true
  dataset: application_log
  table: activity_$TABLENAME_{{ env.bq_target_date }}
  schema_file: /s3_to_bigquery/embulk/db/$TABLENAME.json
  open_timeout_sec: 300
  send_timeout_sec: 300
  read_timeout_sec: 300
  auto_create_gcs_bucket: false
  gcs_bucket: {{ env.EMBULK_OUTPUT_GCS_BUCKET }}
  compression: GZIP
  source_format: NEWLINE_DELIMITED_JSON
  default_timezone: "Asia/Tokyo"
  default_timestamp_format: '%Y-%m-%d %H:%M:%S'
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

### 上記のjsonファイルの1行目に追加するように
gsed -i -e '1i [' -e '$a ]' ${FILEPATH}/embulk/db/${TABLENAME}.json

### add embulk yml file column ###
for j in $(echo ${COLUMN} | gsed 's/,/ /g'); do
cat << EOD
    - {name: "$j", type: "xxx"}
EOD
## 上記のヒアドキュメントの出力を15行目に追加するように
done | xargs -I ARG  gsed -i "15i\ \ \ \ ARG" ${FILEPATH}/embulk/${TABLENAME}.yml.liquid

### jsonは末尾に,が使えず、embulkでjsonのparseエラーになってしまうので削除する
[ -f tmp.json ] && rm -f tmp.json
tail -r ${FILEPATH}/embulk/db/${TABLENAME}.json | gsed '2,1s/,//g' > ${FILEPATH}/embulk/db/${TABLENAME}.json2 \
&& rm -f ${FILEPATH}/embulk/db/${TABLENAME}.json \
&& tail -r ${FILEPATH}/embulk/db/${TABLENAME}.json2 > ${FILEPATH}/embulk/db/${TABLENAME}.json \
&& rm -f ${FILEPATH}/embulk/db/${TABLENAME}.json2
echo ${TABLENAME}.json done!

echo -e "\n下記の${TABLENAME}.jsonに型を追加してください!!
${COLUMN}"
