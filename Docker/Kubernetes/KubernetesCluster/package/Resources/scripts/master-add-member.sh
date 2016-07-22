#!/bin/bash

# $1 - NAME
# $2 - IP

count=30
echo "Adding member $1 to etcd cluster" >> /tmp/etcd.log

while [ $count -gt 0 ]; do
 /opt/bin/etcdctl cluster-health >> /tmp/etcd.log
 if [ $? -eq 0 ]; then
   out=$((/opt/bin/etcdctl member add "$1" "http://$2:7001") 2>&1)
   if [ $? -ne 0 ]; then
     echo "Member $1 not added. Reason: $out" >> /tmp/etcd.log
     break
   fi
   echo -e "Member $1 has been added\n" >> /tmp/etcd.log
   echo "$out" | grep ETCD_INITIAL_CLUSTER= | cut -f 2 -d '"'
   exit 0
 fi
 echo "Member $1 not added" >> /tmp/etcd.log
 ((count-- ))
 sleep 2
done

cat /tmp/etcd.log
exit 1
