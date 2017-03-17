#!/bin/sh
#creative_rsync

echo `date "+%Y-%m-%d %T"`
date=`/bin/date --date '30 minute ago' +"%Y-%m-%d-%T"`
creativelist=`mysql -h db -u hoge -phogehoge hoge -N -e "select hoge from hoge where updated_at >= \"$date\" and creative_id = 2;"`
for creative in $creativelist
do

  for x in `seq 1 5`; do
    command="test -e /hoge/hoge$creative;echo \$?"
    creativetest=`ssh hoge@server$x $command`
    if [ "$creativetest" != "0" ] ; then
      echo "server$x: $creative: Not found"
      ssh -q hoge@server$x mkdir -p `dirname /hoge/hoge/$creative`
      ssh -q hoge@server rsync -a -e 'ssh -q' /hoge/hoge$creative hoge@server$x:`dirname /hoge/hoge$creative`
    fi
  done
done
echo `date "+%Y-%m-%d %T"`
