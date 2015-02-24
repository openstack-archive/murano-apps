#!/bin/bash

# $1 - NAME
# $2 - IP
#
service etcd stop
mkdir /var/lib/etcd

sed -i.bkp "s/%%NAME%%/$1/g" master-etcd-config.conf
sed -i.bkp "s/%%IP%%/$2/g" master-etcd-config.conf

cp -f master-etcd-config.conf /etc/default/etcd
service etcd start
sleep 5