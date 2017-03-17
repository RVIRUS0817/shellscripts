# /bin/sh

#あってもなくても
#LOG=*-`date +\%Y-\%m-\%d --date "-1 days"`.log

#for文ですべてのテーブルを回す
for x in adachin01 adachin02 adachin03 adachin04; do
    CSV=/db/$x-`date +\%Y-\%m-\%d`.csv
    OLD_CSV=/db/$x-`date +\%Y-\%m-\%d --date "-1 days"`.csv

    #csvにすべて出力
    mysql -h IP -u adachin '-passdayo' --database=adachin -e "select * from $x" | sed 's/\t/","/g;s/^/"/;s/$/"/;s/\n//g' > $CSV
    #csvから独自DBにインポート
    mysql -h rdsadachin -P 3306 -u root -passdayo --database=adachindb -e "LOAD DATA LOCAL INFILE '$CSV' REPLACE INTO TABLE $x FIELDS TERMINATED BY ',' ENCLOSED BY '\"' IGNORE 1 LINES;"

     #一日前のcsvを削除
     rm -rf $OLD_CSV $LOG

done

---
・cron
MAILTO =adachin@~
0 0 * * * (/scripts/db_csv_replication.sh 2>&1 >> /var/log/scripts.log) | tee -a /var/log/scripts.log

--

2:#テーブルの設定内容確認し下記のように作成する
show create table adachin01\G
~省略
`id` int(11) NOT NULL AUTO_INCREMENT,
`username` varchar(50) NOT NULL,
`password` varchar(50) NOT NULL,
`authority` varchar(1000) NOT NULL,
`date` int(11) NOT NULL,
PRIMARY KEY (`id`)
) ENGINE=innodb AUTO_INCREMENT=46 DEFAULT CHARSET=utf8


3:#テーブル作成
CREATE TABLE `adachin01` (
`id` int(11) NOT NULL AUTO_INCREMENT,
`username` varchar(50) NOT NULL,
`password` varchar(50) NOT NULL,
`authority` varchar(1000) NOT NULL,
`date` int(11) NOT NULL,
PRIMARY KEY (`id`)
) ENGINE=innodb AUTO_INCREMENT=46 DEFAULT CHARSET=utf8;
