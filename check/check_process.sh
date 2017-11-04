#!/bin/sh

#check zabbix-server

processName01=zabbix
processName02=nagios
processName03=mysqld
processName04=httpd

##zabbix##

    Alive=`pgrep "$processName01" | wc -l`
    if [ $Alive = 0 ]; then
        echo "zabbix is dead."
        /etc/init.d/zabbix-server start
        echo "zabbix is running "
        echo "server01:zabbix $processName01 not running. but it was started." | mail -s "$processName01 not running"       adachin@
    else
        echo "zabbix is running."
        
    fi

##nagios##

    Alive=`pgrep "$processName02" | wc -l`
    if [ $Alive = 0 ]; then
        echo "nagios is dead."
        /etc/init.d/nagios start
        echo "nagios is running "
        echo "server01:zabbix $processName02 not running. but it was started." | mail -s "$processName02 not running"       adachin@
    else
        echo "nagios is running."
        
    fi

##mysqld##

    Alive=`pgrep "$processName03" | wc -l`
    if [ $Alive = 0 ]; then
        echo "mysql is dead."
        /etc/init.d/mysqld start
        echo "mysql is running "
        echo "server01:zabbix $processName03 not running. but it was started." | mail -s "$processName03 not running"       adachin@
    else
        echo "mysql is running."
        
    fi

##httpd##

    Alive=`pgrep "$processName04" | wc -l`
    if [ $Alive = 0 ]; then
        echo "httpd is dead."
        /etc/init.d/httpd start
        echo "httpd is running "
        echo "server01:zabbix $processName04 not running. but it was started." | mail -s "$processName04 not running"       adachin@
    else
        echo "httpd is running."
        
   fi

  #cron
   0 */1 * * *  check-zabbix.sh
   
  #done
$ ./check-zabbix.sh
zabbix is running.
nagios is running.
mysql is running.
httpd is running.
