#!/bin/bash
 
PROFILE=$1
 
help() {
        echo "
          下記のようにログインしたいApp名を指定してください
            ecs-exec adachin
            ecs-exec wikiadachin
 
                "
        }
 
if [ $# -ne 1 ];then
         help
         exit
fi
 
COUNT_TASK=$(aws --profile=${PROFILE} ecs list-tasks --cluster ${PROFILE} --service-name ${PROFILE}-app --output text | sed -e 's/\s/ /g' | cut -d ' ' -f2 | cut -c 46-)
echo "現在のAppコンテナ数"
echo "${COUNT_TASK}"
 
TASK=$(aws --profile=${PROFILE} ecs list-tasks --cluster ${PROFILE} --service-name ${PROFILE}-app --output text | sed -e 's/\s/ /g' | cut -d ' ' -f2 | cut -c 46- |sed -e '2,$d')
echo -e ""
echo "・login"
echo "${TASK}"
 
aws --profile=${PROFILE} ecs execute-command  \
    --region ap-northeast-1 \
    --cluster ${PROFILE} \
    --task "${TASK}" \
    --container ${PROFILE}-app \
    --interactive \
    --command "/bin/bash"
