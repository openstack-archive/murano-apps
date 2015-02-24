#!/bin/bash

# $1 - NAME
# $2 - IP
count=5
done=false

while  [ $count -gt 0 ] && [ "$done" != "true" ]
do
  /opt/bin/etcdctl member add $1 http://$2:7001  > /tmp/out && done="true"
  ((count-- ))
  sleep 2
done
cat /tmp/out | grep ETCD_INITIAL_CLUSTER | grep -n 1 | cut -f 2 -d'"'