# /bin/sh

SERVERDIR=/home/adachin/work/server/http-conf
REPODIR=/home/adachin/work/server/httpd-conf
HTTPDIR=/etc/httpd/conf/local

#各サーバに飛ばす
for x in `seq 1 20`; do
  echo "server$x"
  scp $REPODIR/httpd.conf adachin@server$x:$SERVERDIR
  ssh -t adachin@server$x sudo cp -r $SERVERDIR/httpd.conf $HTTPDIR
done

#apacheのconfを各サーバに送り自動化。ansibleやるまでもないからシェルスクリプトで。

