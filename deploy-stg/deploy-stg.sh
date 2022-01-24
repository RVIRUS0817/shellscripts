#!/bin/bash

BRANCHNAME=$1

url=""
username='stg-deploy'
to="deploy_room"
subject='stgデプロイが完了しました:hammer_and_wrench:'
color="#0000FF"
message="ブランチ名: \`"${BRANCHNAME}"\` https://xxxxxxxxxx/test"

help() {
echo "
  下記のようにブランチを指定して実行してください。
  (例)  ~/deploy/deploy-stg.sh ブランチ名
    "
}

if [ $# -ne 1 ];then
 help
exit
fi

## deploy stg-app
echo -e "\ndeploy stg-app"
echo -e "\n"

ssh stg-app 'cd ~/app' \
'&& git branch' \
'&& git checkout master' \
'&& git pull' \
'&& git branch -D '${BRANCHNAME}'' \
'&& git checkout '${BRANCHNAME}'' \
'&& git branch' \
'&& composer install  --no-dev' \
'&& php artisan config:clear' \
'&& php artisan cache:clear' \
'&& php artisan view:clear' \
'&& php artisan migrate'

echo -e "\n"

echo "
  ブランチ名/ "${BRANCHNAME}" のstgデプロイを開始しました。
  #deploy_roomにて確認しましょう。
"
payload="payload={
  \"channel\":    \"${to}\",
  \"username\":   \"${username}\",
  \"text\":       \"${subject}\",
  \"attachments\": [
    {
      \"color\" : \"${color}\",
      \"text\"  : \"${message}\",
    }
  ]
}"

curl -m 5 --data-urlencode "${payload}" ${url}
