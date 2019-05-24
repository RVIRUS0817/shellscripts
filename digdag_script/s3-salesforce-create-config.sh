#!/bin/bash

TABLENAME=$1
COLUMN=$2
CSV=$3
SCRIPT_DIR=$(cd $(dirname $0); pwd)
FILEPATH="${SCRIPT_DIR}/../salesforce_s3_to_bigquery/"

help() {
echo "
  Type:
  (例) ./s3-salesforce-create-config.sh テーブル名 カラム名(カンマ区切り) CSV名
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

## digdag file ###
cat << EOD > ${FILEPATH}/${TABLENAME}.dig
_export:
  s3_target_date: \${moment(session_date).subtract(1,'days').format('YYYY-MM-DD')}
  bq_target_date: \${moment(session_date).subtract(1,'days').format('YYYYMMDD')}

_error:
  sh>: export \$(cat config/env | xargs) && /opt/redash/digdag/post_slack.sh "[\${session_time}][\${session_id}] DigDag Fail ${TABLENAME}"

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
  path_prefix: db/salesforce/${TABLENAME}/dt={{ env.s3_target_date }}/
  bucket: {{ env.EMBULK_INPUT_S3_BUCKET }}
  access_key_id: {{ env.AWS_ACCESS_KEY }}
  secret_access_key: {{ env.AWS_SECRET_KEY }}
  decoders:
  - {type: gzip}
  parser:
    type: jsonpath
    charset: UTF-8
    newline: CRLF
    columns:
EOD

## embulkファイルにoutを追加 ### 
echo "
out:
  type: bigquery
  mode: replace
  auth_method: json_key
  json_keyfile: /opt/redash/digdag/salesforce_s3_to_bigquery/config/bq.key
  {% if env.EMBULK_ENV == 'production' %}
    {% include 'db/prod_bigquery' %}
  {% else %}
    {% include 'db/pre_bigquery' %}
  {% endif %}
  auto_create_dataset: true
  auto_create_table: true
  dataset: source__sfdc
  table: ${TABLENAME}_{{ env.bq_target_date }}
  schema_file: /opt/redash/digdag/salesforce_s3_to_bigquery/embulk/db/$TABLENAME.json
  open_timeout_sec: 300
  send_timeout_sec: 300
  read_timeout_sec: 300
  auto_create_gcs_bucket: false
  gcs_bucket: {{ env.EMBULK_OUTPUT_GCS_BUCKET }}
  compression: GZIP
  source_format: NEWLINE_DELIMITED_JSON
  default_timezone: "Asia/Tokyo"
  default_timestamp_format: '%Y-%m-%d %H:%M:%S'
"  >> $FILEPATH/embulk/${TABLENAME}.yml.liquid
echo ${TABLENAME}.yml.liquid done!

## csvの型をjsonファイルに自動追記 ###
while read row; do
  column1=$(echo ${row} | cut -d , -f 1)
  column2=$(echo ${row} | cut -d , -f 2)
  #echo $column2

    # 改行
    column2=$(echo ${column2} | gsed -E 's/\n//g')
    #echo $column2
    
    #前方一致
    if [[ "$column2" =~ "datetime" ]]; then
      column2=$(echo "DATETIME")
    elif [[ "$column2" =~ "bigint" ]]; then
      column2=$(echo "INT64")    
    elif [[ "$column2" =~ "int" ]]; then
      column2=$(echo "INT64")    
    elif [[ "$column2" =~ "decimal" ]]; then
      column2=$(echo "FLOAT")
    else  
      column2=$(echo "STRING")
    fi

  echo  "    {
        \"name\": \"${column1}\",
        \"type\": \"${column2}\"
    }, "
      
done < ${CSV} > ${FILEPATH}/embulk/db/${TABLENAME}.json

### 上記のjsonファイルの1行目に追加するように
gsed -i -e '1i [' -e '$a ]' ${FILEPATH}/embulk/db/${TABLENAME}.json

### add embulk yml file column ###
for j in $(echo ${COLUMN} | gsed 's/,/ /g'); do
cat << EOD 
    - {name: "$j", type: "string"}
EOD
## 上記のヒアドキュメントの出力を15行目に追加するように
done | xargs -I ARG  gsed -i "14i\ \ \ \ ARG" ${FILEPATH}/embulk/${TABLENAME}.yml.liquid

### jsonは末尾に,が使えず、embulkでjsonのparseエラーになってしまうので削除する
[ -f tmp.json ] && rm -f tmp.json
tail -r ${FILEPATH}/embulk/db/${TABLENAME}.json | gsed '2,1s/,//g' > ${FILEPATH}/embulk/db/${TABLENAME}.json2 \
&& rm -f ${FILEPATH}/embulk/db/${TABLENAME}.json \
&& tail -r ${FILEPATH}/embulk/db/${TABLENAME}.json2 > ${FILEPATH}/embulk/db/${TABLENAME}.json \
&& rm -f ${FILEPATH}/embulk/db/${TABLENAME}.json2
echo ${TABLENAME}.json done!
