#!/bin/bash

set -e

## Current goval/go-cve-dictionary,Vuls version

echo -e "----Current goval/go-cve-dictionary/gost,Vuls version----"
docker run  --rm  vuls/go-cve-dictionary -v
docker run  --rm  vuls/goval-dictionary -v
docker run  --rm  vuls/gost  -v
docker run  --rm  vuls/vuls -v

## Update go-cve-dictionary
echo -e "\n----Update go-cve-dictionary----"
docker pull vuls/go-cve-dictionary > /dev/null 2>&1

if [ $? = 0 ]; then
  echo "Update OK"
else
  echo "Update NO!!"
fi

## Update goval-dictionary
echo -e "\n----Update goval-dictionary----"
docker pull vuls/goval-dictionary > /dev/null 2>&1

if [ $? = 0 ]; then
  echo "Update OK"
else
  echo "Update NO!!"
fi

## Update gost
echo -e "\n----Update gost----"
docker pull vuls/gost > /dev/null 2>&1

if [ $? = 0 ]; then
  echo "Update OK"
else
  echo "Update NO!!"
fi

## Update Vuls
echo -e "\n----Update Vuls----"
docker pull vuls/vuls > /dev/null 2>&1

if [ $? = 0 ]; then
  echo "Update OK"
else
  echo "Update NO!!"
fi


echo -e "\n----New goval/go-cve-dictionary,Vuls version----"
docker run  --rm  vuls/go-cve-dictionary -v
docker run  --rm  vuls/goval-dictionary -v
docker run  --rm  vuls/gost  -v
docker run  --rm  vuls/vuls -v

