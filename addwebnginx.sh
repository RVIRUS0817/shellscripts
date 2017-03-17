#!/bin/sh

while getopts s:r:a:e:p: opt
do
   case ${opt} in
    s)
        SERVERNAME=${OPTARG};;
    r)
        ROOTDIR=${OPTARG};;
    a)
        ALOG=${OPTARG};;
    e)
        ELOG=${OPTARG};;
    p)
        PORT=${OPTARG};;

    *)
  exit 1;;
  esac
done


sed -i "s/www.hoge.jp/$SERVERNAME/g" /etc/nginx/test
sed -i "s/hoge.jp/$ROOTDIR/g" /etc/nginx/test
sed -i "s/www_hoge.access.log/$ALOG/g" /etc/nginx/test
sed -i "s/www_hoge.error.log/$ELOG/g" /etc/nginx/test
sed -i "s/hoge/$PORT/g" /etc/nginx/test
