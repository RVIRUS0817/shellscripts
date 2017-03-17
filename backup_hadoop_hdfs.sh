#!/bin/bash
#===============================================================================
# ログをサーバへバックアップ(hdfs)
#===============================================================================

#===============================================================================
# 日付設定
#===============================================================================
if [ $# -eq 1 ]; then
    DATE=`/bin/date --date '1 day ago' +\%Y/%m/%d`
fi

if [ $# -eq 2 ]; then
        DATE=$2
fi

if [ $# -eq 3 ]; then
    NODATE=`/bin/date --date '1 day ago' +\%Y/%m`
fi

if [ $# -eq 4 ]; then
        NODATE=$3
fi


DATE=`/bin/date --date '1 day ago' +\%Y/%m/%d`
NO_SLASH_DATE=`echo ${DATE}`

NODATE=`/bin/date --date '1 day ago' +\%Y/%m`
NO_SLASH_NODATE=`echo ${NODATE}`


#===============================================================================
# 共通環境変数
#=============================================================================
HDFS_BASE_DIR="/user/hdfs/hoge"
HOGE_BSSE_DIR="/data/hoge"

#===============================================================================
# hoge バックアップ
#=============================================================================
echo "[hoge バックアップ `date +'%Y/%m/%d %k:%M:%S'`]"

HDFS_SEGUEMT_USERSUM_DIR="${HDFS_BASE_DIR}/hoge/${DATE}"
LOCAL_SEGMENT_USERSUM_BASE_DIR="${HOGE_BSSE_DIR}/hoge"
LOCAL_SEGMENT_USERSUM_TARGET_DATE_DIR="${LOCAL_SEGMENT_USERSUM_BASE_DIR}/${NO_SLASH_DATE}"


echo "sudo -u hdfs mkdir -p ${LOCAL_SEGMENT_USERSUM_TARGET_DATE_DIR}"   
sudo -u hdfs mkdir -p "${LOCAL_SEGMENT_USERSUM_TARGET_DATE_DIR}"

echo "sudo -u hdfs hadoop fs -copyToLocal ${HDFS_SEGUEMT_USERSUM_DIR}/* ${LOCAL_SEGMENT_USERSUM_TARGET_DATE_DIR}"  
sudo -u hdfs hadoop fs -copyToLocal ${HDFS_SEGUEMT_USERSUM_DIR}/* ${LOCAL_SEGMENT_USERSUM_TARGET_DATE_DIR}
