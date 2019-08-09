#!/bin/bash

set -e

help()
{
echo "
  Type:
  (例)このように指定してあげましょう! 201805 01 08 FILENAME
    "
}

if [ $# -ne 4 ];then
  help
  exit
fi

YEARMONTH=$1
FROM01="$2"
TO01="$3"
PROJECT=ga_to_bigquery
FILENAME="$4"

### Past log digdag
for i in $(seq -w $2 $3);do
  DATE1=$1$i
  DATE2=$(echo ${DATE1} | sed "s/\([0-9]\{4\}\)\([0-9]\{2\}\)\([0-9]\{2\}\)/\1-\2-\3/g")

echo "timezone: Asia/Tokyo
schedule:
  daily>: 03:00:00
_retry: 6
_export:
  project_id: \${settings.gcp.project_id}
  private_key_id: \${settings.gcp.private_key_id}
  private_key: \${settings.gcp.private_key}
  client_email: \${settings.gcp.client_email}
  client_id: \${settings.gcp.client_id}
  client_x509_cert_url: \${settings.gcp.client_x509_cert_url}
  ga_target_date: VAR1
  bq_target_date: VAR2
  bq: 'sudo -u lancers /home/lancers/google-cloud-sdk/bin/bq'
  settings:
    !include : config/settings.dig
_error:
  sh>: /digdag/post_slack.sh \"[\${session_time}][\${session_id}] DigDag Fail ga\"
+repeat:
  for_each>:
     view_id: [xxxxxxxxxx, xxxxxxxxxxxx]
  _do:
    sh>: export \$(cat config/env | xargs) && /usr/local/bin/embulk run -b \$EMBULK_BUNDLE_PATH embulk/ga.yml.liquid
+bq_copy:
  sh>: \${bq} cp -f ga.test_\${bq_target_date} ga.test_\${bq_target_date}" | sed -e "s/VAR1/${DATE2}/g" -e "s/VAR2/${DATE1}/g" > ../ga_to_bigquery/${FILENAME}.${DATE1}.dig


DIGDAGFILE=${FILENAME}.${DATE1}.dig

echo "=== delete .digdag  ==="
cd ../ga_to_bigquery && rm -rf .digdag/status/*

echo "=== digdag run old ==="
cd ../ga_to_bigquery && digdag run ${DIGDAGFILE}

echo "=== delete old.dig"
cd ../ga_to_bigquery && rm -rf ${FILENAME}.${DATE1}.dig

done
