#!/bin/bash
#### Past log S3 to BigQuery #### 

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
### add project name
PROJECT=adachin-server-lab-log-s3
FILENAME="$4"

### new log digdag(start)
echo "=== digdag run new ==="
digdag run ${FILENAME}.dig

echo "=== digdag push ==="
digdag push ${PROJECT}

echo "=== digdag workflows ==="
digdag workflows
### new log digdag(end)

### Past log digdag(start)
for i in $(seq -w $2 $3);do
    DATE1=$1$i
    DATE2=$(echo ${DATE1} | sed "s/\([0-9]\{4\}\)\([0-9]\{2\}\)\([0-9]\{2\}\)/\1-\2-\3/g")

echo "_export:
  s3_target_date: VAR1
  bq_target_date: VAR2
_error:
  sh>: export \$(cat config/env | xargs) && /opt/redash-ops/digdag/xxxxxxxx.sh \"[\${session_time}][\${session_id}] DigDag Fail ${FILENAME}\"
+load:
  sh>: export \$(cat config/env | xargs) && /usr/local/bin/embulk run -b \$EMBULK_BUNDLE_PATH embulk/${FILENAME}.yml.liquid" | sed -e "s/VAR1/${DATE2}/g" -e "s/VAR2/${DATE1}/g" > ${FILENAME}.${DATE1}.dig

DIGDAGFILE=${FILENAME}.${DATE1}.dig

echo "=== delete .digdag  ==="
rm -rf .digdag/status/*

echo "=== digdag run old ==="
digdag run ${DIGDAGFILE}

echo "=== delete old.dig ==="
rm -rf ${FILENAME}.${DATE1}.dig

done
### Past log digdag(end)
