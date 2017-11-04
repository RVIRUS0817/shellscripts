#!/bin/bash

#変数(testファイル/一時間前のtestファイル)
TEST=/hoge/test.txt.`date "+%Y%m%d-%H%M"`
TESTRM=/hoge

#一日前のtestファイルを削除
ssh -q adachin@lsyncd sudo -u adachin find $TESTRM -mtime +0 -exec rm -f {} \;

echo `date "+%Y-%m-%d %T"`
#testファイルをtouch
ssh -q adachin@lsyncd sudo -u adachin touch $TEST
sleep 10s

#for文でserver1~20までtestファイルがあるのか確認
for x in `seq 1 20`; do
    echo "server$x"
      if [[ `ssh adachin@server$x "ls $TEST"` != "$TEST" ]]; then
        echo "Not a test file！"
        #slackとメールに飛ばす
        echo Not a test file | ./webhooks.sh
        echo "server$x not a touch file" | mail -s "server$x not touch file" adachin@adachin.com
     else
        echo "test file OK"
     fi
done

#cronで毎時15分に確認
15 * * * * check_touch.sh
