#!/bin/bash
count=30

echo "Adding flannel configuration to etcd"

command=$((/opt/bin/etcdctl set /coreos.com/network/config '{"Network":"10.200.0.0/16"}') 2>&1)

while [ $count -gt 0 ]; do
 if [ $command ]; then
   echo "Flannel is configured on master node" >> /tmp/etcd.log
   exit 0
 fi
 echo "Flannel configuration was not added. Reason: $command"
 ((count-- ))
 sleep 5
done
exit 1
