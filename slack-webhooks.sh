ncoming WebHooksのURL
WEBHOOKURL="Incoming Webhooks Integration URL"
#メッセージを保存する一時ファイル
MESSAGEFILE=$(mktemp -t webhooks)
#slack 送信チャンネル
CHANNEL="#general"
#slack 送信名
BOTNAME="mybot"
#slack アイコン
FACEICON=":ghost:"
 
if [ -p /dev/stdin ] ; then
    #改行コードをslack用に変換
    cat - | tr 'n' '\' | sed 's/\/\n/g'  > ${MESSAGEFILE}
else
    echo "nothing stdin"
    exit 1
fi
 
WEBMESSAGE=`cat ${MESSAGEFILE}`
 
#Incoming WebHooks送信
curl -s -S -X POST --data-urlencode "payload={"channel": "${CHANNEL}", "username": "${BOTNAME}", "icon_emoji": "${FACEICON}", "text": "${WEBMESSAGE}" }" ${WEBHOOKURL} >/dev/null
 
#一時ファイルの削除
rm ${MESSAGEFILE}
