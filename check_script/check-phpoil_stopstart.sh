#!/bin/bash

PROCCESS=php
ALIVE=`pgrep -f "$PROCCESS" | wc -l`

echo "===check proccess php oil===" 
pgrep -f php

echo "===check php oil ===" 
  if [ $ALIVE = 3 ]; then
    echo "stop php oil." 
    sudo -u user /var/www/php ./oil refine Watchdog:freeze
  elif [ $ALIVE = 0 ]; then
    echo "start php oil." 
    sudo -u user /var/www/php ./oil refine Watchdog:unfreeze
  fi

echo "===status check, php oil /var/tmp===" 
  ls -l /var/tmp
  pgrep -f php
