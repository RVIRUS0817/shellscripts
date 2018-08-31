#!/bin/bash

url='https://hooks.slack.com/services/xxxxxxxxxxxxxxxxxxxxxxxxxxxx'
username='DigDag'
to="sre"
subject='FAILED'
emoji=':digdag:'
message="$1"
color="#FF0000"

payload="payload={
  \"channel\":    \"${to}\",
  \"username\":   \"${username}\",
  \"text\":       \"${subject}\",
  \"icon_emoji\":  \"${emoji}\",
  \"attachments\": [
    {
      \"color\" : \"${color}\",
      \"text\"  : \"${message}\"
    }
  ]
}"

curl -m 5 --data-urlencode "${payload}" $url
