#!/bin/bash

# $1 - MASTER_IP

cp -f haproxy.toml /etc/confd/conf.d/
cp -f haproxy.tmpl /etc/confd/templates/

/usr/local/bin/confd -onetime -backend etcd -node $1:4001

cp -f default_scripts/haproxy /etc/default/

sed -i.bkp "s/%%MASTER_NODE%%/$1/g" init_conf/confd.conf
cp -f init_conf/confd.conf /etc/init/

service confd start
service haproxy start

sleep 1