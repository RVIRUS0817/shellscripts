#置換
#!/bin/sh

while getopts c:r:s: opt
do
   case ${opt} in
    s)
        SERVERALIAS=${OPTARG};;
    c)
        REWITECOND=${OPTARG};;
    r)
        REWITERULE=${OPTARG};;
    *)
  exit 1;;
  esac
done

cp /etc/httpd/conf.d/httpd.conf /var/tmp
sed -i "s/ADD01/$SERVERALIAS/g" httpd.conf
sed -i "s/ADD02/$REWITECOND/g" httpd.conf
sed -i "s/ADD03/$REWITERULE/g" httpd.conf
diff -u /etc/httpd/conf.d/httpd.conf /var/tmp/httpd.conf
--------------------

#行数指定
#!/bin/sh

while getopts c:r:s: opt
do
   case ${opt} in
    c)
        REWITECOND=${OPTARG};;
    r)
        REWITERULE=${OPTARG};;
    s)
        SERVERALIAS=${OPTARG};;
    *)
  exit 1;;
  esac
done

cp /etc/httpd/conf.d/httpd.conf /var/tmp
sed -i "83a \  \RewriteCond %{HTTP_HOST} $REWITECOND\\\.jp$ [NV]" httpd-40.conf
sed -i "84a \  \RewriteRule ^/js/(.*) /hoge/js/$REWITERULE/\$1\ [L]" httpd-40.conf
sed -i "24a \  \ServerAlias *.$SERVERALIAS" httpd-40.conf
mkdir -p /hoge/js/$REWITERULE
chown -R adachin.wheel /hoge/js/$REWITERULE
diff -u /etc/httpd/conf.d/httpd.conf /var/tmp/httpd-40.conf
----------

#sedファイルを用いたファイルへの挿入

・serveralias.sed
/*.adachin.com/a\ #ServerAliasの最後段落のドメイン名を確認 
  ServerAlias *.test.com #今回入れたいドメイン名
  
・rewiterule.sed
/adachin/a\ #RewriteRuleの最後段落のjsディレクトリの確認
  RewriteRule ^/js/(.*) /js/test/$1 [L] #jsディレクトリ
  
・rewritecond.sed
/adachin/a\ #RewriteRuleの最後の段落のjsディレクトリの確認
  RewriteCond %{HTTP_HOST} test\\\.com$ [NV] #今回入れたいドメイン名(.comか.jpなのか確認すること!)  
  
#!/bin/sh

while getopts r: opt
do
   case ${opt} in
    r)
        REWITERULE=${OPTARG};;
    *)
  exit 1;;
  esac
done

#コピー
cp /etc/httpd/conf/local/httpd.conf /var/tmp

#serveralias.sed,rewiterule.sed,rewritecond.sedを適用
sed -i -f serveralias.sed /etc/httpd/conf/local/httpd.conf
sed -i -f rewiterule.sed /etc/httpd/conf/local/httpd.conf
sed -i -f rewritecond.sed /etc/httpd/conf/local/httpd.conf

#jsディレクトリの作成/権限変更
mkdir -p /js/$REWITERULE
chown -R adachin.wheel /js/$REWITERULE

#差分の確認
diff -u /etc/httpd/conf/local/httpd.conf /var/tmp/httpd.conf
