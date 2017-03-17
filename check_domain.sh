#!/bin/sh


FQDN=$1
echo `date "+%Y-%m-%d %T"`

for SFQDN in `cat $FQDN`
do
        DM=`echo $SFQDN | cut -d"," -f1`
        SDM=`echo $SFQDN | cut -d"," -f2`
        URL="http://"$SDM"/js/a.js"
        echo -n $DM" :"
        ALIVE=`curl $URL -s | grep -o $DM | wc -l`

      if [ "$ALIVE" = '0' ]; then
         echo "advertising is dead."
         echo -e "deliver: "$DM" advertising not running!!!!" | mail -s "advertising not running"  adachi@

      else
         echo "advertising is running."

      fi
done


------
./check_domain.sh host
2016-03-10 21:57:07
adachin.jp : advertising is dead


・cron
*/10 * * * * check_domain.sh host 
