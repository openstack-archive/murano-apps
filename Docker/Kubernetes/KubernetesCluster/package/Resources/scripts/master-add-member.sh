#!/bin/bash

# $1 - NAME
# $2 - IP
count=30

while [ $count -gt 0 ]; do
 out=$(/opt/bin/etcdctl member add "$1" "http://$2:7001")
 if [ $? -eq 0 ]; then
   echo "$out" | grep ETCD_INITIAL_CLUSTER= | cut -f 2 -d '"'
   exit 0
 fi
 ((count-- ))
 sleep 2
done
exit 1
