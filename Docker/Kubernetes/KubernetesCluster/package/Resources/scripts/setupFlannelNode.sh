#!/bin/bash

if [[ $(which systemctl) ]]; then
  cp -f systemd/docker.service /lib/systemd/system/
  cp -f systemd/flanneld.service /etc/systemd/system/

  systemctl daemon-reload
  systemctl enable flanneld
  systemctl start flanneld

else
  cp init_conf/flanneld.conf /etc/init/
  chmod +x initd_scripts/flanneld
  cp initd_scripts/flanneld /etc/init.d/
  cp default_scripts/flanneld /etc/default/

  service flanneld start
fi

source /run/flannel/subnet.env 2> /dev/null
while [ -z "$FLANNEL_SUBNET" ]
do
  sleep 1
  source /run/flannel/subnet.env 2> /dev/null
done


ip link set dev docker0 down
brctl delbr docker0

echo "DOCKER_OPTS=-H tcp://127.0.0.1:4243 -H unix:///var/run/docker.sock --bip=${FLANNEL_SUBNET} --mtu=${FLANNEL_MTU}" > /etc/default/docker

echo post-up iptables -t nat -A POSTROUTING -s 10.200.0.0/16 ! -d 10.200.0.0/16 -j MASQUERADE >>  /etc/network/interfaces.d/eth0.cfg
iptables -t nat -A POSTROUTING -s 10.200.0.0/16 ! -d 10.200.0.0/16 -j MASQUERADE

service docker restart

