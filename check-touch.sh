#!/bin/bash

hoge1=/hoge/test.txt.`date "+%Y%m%d-%H%M"`
hogerm=/hoge/test.txt.`date -d '1 hours ago' +%Y%m%d-%H%M`

echo `date "+%Y-%m-%d %T"`
ssh -q adachin@lsyncd sudo -u adachin touch $hoge

for x in `seq 1 10`; do
    echo "server$x" 
      if [[ `ssh adachin@hoge$x "sleep 5;ls $hoge1"` != "$hoge1" ]]; then
        echo "ファイルが存在しません" 
       echo Notfile | ./webhooks.sh
        echo "server$x not touch file" | mail -s "server$x not touch file" adachin@
     else
        echo "ファイルが存在します" 
     fi
done

rm -rf $hogerm

#cron
15 * * * * check_touch.sh 
