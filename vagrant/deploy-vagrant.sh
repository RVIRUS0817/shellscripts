#!/bin/bash

STATUSNAME=$1
DIR=~/vagrant/stg

help() {
echo "
  下記のようにstatusを指定して実行しろや！！
  (例) ./deploy-vagrant.sh status,up,suspend
    "
}

if [ $# -ne 1 ];then
 help
exit
fi

cd ${DIR} && vagrant ${STATUSNAME}

