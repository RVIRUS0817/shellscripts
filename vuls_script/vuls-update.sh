#!/bin/bash

set -e

GOCVEDICTIONARY=$GOPATH/src/github.com/kotakanbe/go-cve-dictionary
GOVALDICTIONARY=$GOPATH/src/github.com/kotakanbe/goval-dictionary
VULS=$GOPATH/src/github.com/future-architect/vuls

## Current goval/go-cve-dictionary,Vuls version

echo -e "----Current goval/go-cve-dictionary,Vuls version----"
go-cve-dictionary -v
goval-dictionary -v
vuls -v

## Update go-cve-dictionary

echo -e "\n----Update go-cve-dictionary----"
cd $GOCVEDICTIONARY && git pull > /dev/null 2>&1 && rm -rf vendor && rm -rf $GOPATH/pkg && make install > /dev/null 2>&1

if [ $? = 0 ]; then
  echo "Update OK"
else
  echo "Update NO!!"
fi

## Update goval-dictionary

echo -e "\n----Update goval-dictionary----"
cd $GOVALDICTIONARY && git pull  > /dev/null 2>&1  && rm -rf vendor && rm -rf $GOPATH/pkg && make install > /dev/null 2>&1

if [ $? = 0 ]; then
  echo "Update OK"
else
  echo "Update NO!!"
fi

## Update Vuls

echo -e "\n----Update Vuls----"
cd $VULS && git pull  > /dev/null 2>&1 && rm -rf vendor && rm -rf $GOPATH/pkg && make install > /dev/null 2>&1

if [ $? = 0 ]; then
  echo "Update OK"
else
  echo "Update NO!!"
fi

## New goval/go-cve-dictionary,Vuls version

echo -e "\n----New goval/go-cve-dictionary,Vuls version----"
go-cve-dictionary -v
goval-dictionary -v
vuls -v
