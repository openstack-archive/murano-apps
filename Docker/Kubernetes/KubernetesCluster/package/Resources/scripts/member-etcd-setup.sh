#!/bin/bash

# $1 - NAME
# $2 - IP
# $3 - ETCD_INITIAL_CLUSTER

service etcd stop

mkdir /var/lib/etcd
sed -i.bkp "s/%%NAME%%/$1/g" default_scripts/etcd-member
sed -i.bkp "s/%%IP%%/$2/g" default_scripts/etcd-member
sed -i.bkp "s#%%CLUSTER_CONFIG%%#$3#g" default_scripts/etcd-member

cp -f default_scripts/etcd-member /etc/default/etcd
cp init_conf/etcd.conf /etc/init/
chmod +x initd_scripts/etcd
cp initd_scripts/etcd /etc/init.d/

service etcd start

sleep 10