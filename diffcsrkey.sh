#!/bin/bash

while getopts c:k: opt
do
   case ${opt} in
    c)
        CERTFILE=${OPTARG};;
    k)
        KEYFILE=${OPTARG};;
    *)
  exit 1;;
  esac
done

CERT=`/usr/bin/openssl x509 -in $CERTFILE -modulus -noout > CRT.txt`
KEY=`/usr/bin/openssl rsa -in $KEYFILE -modulus -noout > KEY.txt`

result=diff $CERT $KEY

if [ "$result" = "" ];then
     echo "" 
else
     echo "" 
fi

rm CRT.txt KEY.txt
