#/bin/bash

# * * * * * /adachin/make_ssh_config.sh > /etc/ssh/ssh_config

AWS_PROFILE_EC2=ec2
AWS_PROFILE_ECS=ecs

source ~/.bash_profile

describe_instances() {

  IFS=$'\n'

  instances=$( \
     aws ec2 \
       --profile=$1 describe-instances \
       --filter "Name=instance-state-name,Values=running" \
       --query 'sort_by(Reservations[].Instances[].{Tags:Tags[?Key==`Name`].Value|[0],Ip:PrivateIpAddress},&Tags)' \
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
Host $host
  HostName $ip_address
  User adachin 
  Port xxxxxxxx

_EOT_
  done
}

describe_ecs() {

  IFS=$'\n'

  LIST_TASKS=$(aws ecs --profile=$1 list-tasks --cluster adachin | jq -r '.taskArns[]')
  instances=$(for i in ${LIST_TASKS};
  do
    aws ecs --profile=$1 describe-tasks --cluster adachin --tasks $i | jq -r '.tasks[].containers[] | .name + "," + .networkInterfaces[].privateIpv4Address'
  done)

  for instance in ${instances};
  do
    host=$(echo "${instance}" | awk -F',' '{print $1}'| sed -e 's/ .*//g')
    ip_address=$(echo "${instance}" | awk -F',' '{print $2}')

    cat << _EOT_
Host $host
  HostName $ip_address
  User adachin 
  Port xxxxxx
  IdentityFile ~/.ssh/adachin

_EOT_
  done
}

cat << _EOT_
Host *
   StrictHostKeyChecking no
   #UserKnownHostsFile=/dev/null

Host github.com
  User git
  Hostname github.com
  IdentityFile ~/.ssh/github

_EOT_

describe_instances $AWS_PROFILE_EC2
describe_ecs $AWS_PROFILE_ECS

