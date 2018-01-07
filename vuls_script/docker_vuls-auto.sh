#fetchnvd
echo -n $"fetchnvd: "

docker run --rm \
    -v $PWD:/vuls \
    -v $PWD/go-cve-dictionary-log:/var/log/vuls \
    vuls/go-cve-dictionary fetchnvd -last2y

#fetchjvn
echo -n $"fetchjvn: "

docker run --rm \
    -v $PWD:/vuls \
    -v $PWD/go-cve-dictionary-log:/var/log/vuls \
    vuls/go-cve-dictionary fetchjvn -latest

#ubuntu-oval
echo -n $"ubuntu-oval: "

docker run --rm -it \
    -v $PWD:/vuls \
    -v $PWD/go-cve-dictionary-log:/var/log/vuls \
    vuls/goval-dictionary fetch-ubuntu 12 14 16

#redhat-oval
echo -n $"redhat-oval: "

docker run --rm -it \
    -v $PWD:/vuls \
    -v $PWD/go-cve-dictionary-log:/var/log/vuls \
    vuls/goval-dictionary fetch-redhat 5 6 7

#vuls scan
echo -n $"vuls scan: "

docker run --rm \
    -v ~/.ssh:/root/.ssh:ro \
    -v $PWD:/vuls \
    -v $PWD/vuls-log:/var/log/vuls \
    -v /etc/localtime:/etc/localtime:ro \
    -e "TZ=Asia/Tokyo" \
    vuls/vuls scan \
    -config=./config.toml

#vuls report
echo -n $"vuls report: "

docker run --rm \
    -v ~/.ssh:/root/.ssh:ro \
    -v $PWD:/vuls \
    -v $PWD/vuls-log:/var/log/vuls \
    -v /etc/localtime:/etc/localtime:ro \
    vuls/vuls report \
    -cvedb-path=/vuls/cve.sqlite3 \
    -ovaldb-path=/vuls/oval.sqlite3 \
    -format-short-text \
    -to-slack \
    -lang=ja \
    -cvss-over=7 \
    -config=./config.toml
