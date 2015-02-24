#!/bin/bash

# $1 - NAME
# $2 - IP
# $3 - ETCD_INITIAL_CLUSTER

service etcd stop

mkdir /var/lib/etcd
first=`cat member-etcd-config-p1.conf`
echo -n $first > member-etcd-config.conf
echo -n " " >> member-etcd-config.conf
echo -n  $3 >> member-etcd-config.conf
cat member-etcd-config-p2.conf >> member-etcd-config.conf

sed -i.bkp "s/%%NAME%%/$1/g" member-etcd-config.conf
sed -i.bkp "s/%%IP%%/$2/g" member-etcd-config.conf

cp -f member-etcd-config.conf /etc/default/etcd

service etcd start

sleep 10