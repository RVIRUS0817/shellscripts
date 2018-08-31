#!/bin/sh

if [[ 'production' == $DIGDAG_ENV ]] ; then
  body=$1
  room_id=$2

  if [ -z $room_id ]; then
    room_id=xxxxxxxxxx
  fi

  /usr/bin/curl -X POST -H "X-ChatWorkToken:xxxxxxxxxxxx" -d "body=$body" "https://api.chatwork.com/v2/rooms/$room_id/messages"
fi<Paste>
