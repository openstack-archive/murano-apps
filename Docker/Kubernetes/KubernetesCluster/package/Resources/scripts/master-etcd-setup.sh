#!/bin/bash

# $1 - NAME
# $2 - IP
#

if [[ $(which systemctl) ]]; then
  systemctl stop etcd
  mkdir -p /var/lib/etcd

  sed -i.bak "s/%%NAME%%/$1/g" environ/etcd
  sed -i.bak "s/%%IP%%/$2/g" environ/etcd
  sed -i.bak "s/%%STATE%%/new/g" environ/etcd
  sed -i.bak "s/%%CLUSTER_CONFIG%%/$1=http:\/\/$2:7001/g" environ/etcd

  echo 'INITIAL_CLUSTER_TOKEN="--initial-cluster-token new-token"' >> environ/etcd

  cp -f environ/etcd /etc/default/
  cp -f systemd/etcd.service /etc/systemd/system/

  systemctl daemon-reload
  systemctl enable etcd
  systemctl start etcd

else
  service etcd stop
  mkdir /var/lib/etcd

  sed -i.bak "s/%%NAME%%/$1/g" default_scripts/etcd-master
  sed -i.bak "s/%%IP%%/$2/g" default_scripts/etcd-master

  cp -f default_scripts/etcd-master /etc/default/etcd
  cp init_conf/etcd.conf /etc/init/

  chmod +x initd_scripts/*
  cp initd_scripts/etcd /etc/init.d/
  service etcd start
fi

sleep 5