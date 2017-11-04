#!/bin/bash

# LBのMASTERがBACKUPになってたらslackに飛ばす
for x in server01 server02; do
echo "$x"
  if ssh -q adachin@$x cat /var/run/vrrp_status |grep 'BACKUP'; then
  echo "BACUKUP"
  echo ※$x BACUKUP!!!!|/etc/keepalived/scripts/./lb_status.sh
  echo "$x LB BACKUP now" | mail -s "$x LB BACKUP now " adachin@adachin.com
else
 echo "MASTER OK"
  fi
done
