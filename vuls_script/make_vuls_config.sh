#!/bin/bash

# ./make_vuls_config.sh > /home/vuls/vuls/config.toml

AWS_PROFILE=production

source ~/.bash_profile

describe_instances() {

  IFS=$'\n'

  instances=$( \
     aws ec2 \
       --profile=$1 describe-instances \
       --filter "Name=instance-state-name,Values=running" \
       --query 'Reservations[].Instances[].{Tags:Tags[?Key==`Name`].Value|[0],Ip:PrivateIpAddress}' \
       --output text | \
     sort \
   )

   for instance in $instances; do
    ip_address=$(echo "${instance}" | awk '{print $1}')
    host=$(echo "${instance}" | awk '{print $2}'| sed -e 's/ .*//g')
    if [[ ! $host =~ -[0-9]{1,3}-[0-9]{1,3}$ ]]; then
      iptail=$(echo $ip_address | sed -E 's/.*\.([0-9]{1,3})\.([0-9]{1,3})$/-\1-\2/g')
      host=$host$iptail
    fi

cat << _EOT_
[servers.prd-$host]
host    = "$ip_address"
port    = "xxxx"
user    = "xxxx"
keyPath = "/home/xxxx/.ssh/xxxx"
scanMode     = ["fast"]

_EOT_
  done
}

cat << _EOT_
[cveDict]
type = "sqlite3"
path = "/home/vuls/vuls/cve.sqlite3"

[ovalDict]
type = "sqlite3"
path = "/home/vuls/vuls/oval.sqlite3"

[gost]
type = "sqlite3"
path = "/home/vuls/vuls/gost.sqlite3"

[slack]
legacyToken  = "xoxp-xxxx"
channel      = "#xxxx"
iconEmoji    = ":vuls-report:"
authUser     = "vuls-report"

[aws]
profile = "default"
region = "ap-northeast-1"
s3Bucket = "xxxx"
s3ServerSideEncryption = "AES256"

[servers]

_EOT_

describe_instances $AWS_PROFILE

