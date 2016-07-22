#!/bin/bash

# $1 - NAME
# $2 - IP

#Create log folder for Kubernetes services
mkdir -p /var/run/murano-kubernetes

if [[ $(which systemctl) ]]; then
  systemctl stop kube*
  sed -i.bak "s/%%MASTER_IP%%/$2/g" environ/kube-config

  mkdir -p /etc/kubernetes/

  cp -f environ/apiserver /etc/kubernetes/apiserver
  cp -f environ/kube-config /etc/kubernetes/config

  cp -f systemd/kube-apiserver.service /etc/systemd/system/
  cp -f systemd/kube-scheduler.service /etc/systemd/system/
  cp -f systemd/kube-controller-manager.service /etc/systemd/system/

  systemctl daemon-reload

  systemctl enable kube-apiserver
  systemctl enable kube-scheduler
  systemctl enable kube-controller-manager

  systemctl start kube-apiserver
  systemctl start kube-scheduler
  systemctl start kube-controller-manager

else
  service kube-proxy stop
  service kube-scheduler stop
  service kube-controller-manager stop
  service kubelet stop
  service kube-apiserver stop

  #Disable controller-manager for now
  #chmod -x /etc/init.d/kube-controller-manager

  sed -i.bak "s/%%MASTER_IP%%/$2/g" default_scripts/kube-scheduler

  cp -f default_scripts/kube-apiserver /etc/default/
  cp -f default_scripts/kube-scheduler /etc/default/
  cp -f default_scripts/kube-controller-manager /etc/default/

  cp init_conf/kube-apiserver.conf /etc/init/
  cp init_conf/kube-controller-manager.conf /etc/init/
  cp init_conf/kube-scheduler.conf /etc/init/

  chmod +x initd_scripts/*
  cp initd_scripts/kube-apiserver /etc/init.d/
  cp initd_scripts/kube-controller-manager /etc/init.d/
  cp initd_scripts/kube-scheduler /etc/init.d/

  service kube-apiserver start
  service kube-scheduler start
  service kube-controller-manager start
fi

mkdir /var/log/kubernetes
/opt/bin/kubectl delete node 127.0.0.1
sleep 1