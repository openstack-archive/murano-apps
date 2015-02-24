#!/bin/bash

# $1 - NAME
# $2 - IP
# $3 - PORTAL_NET

service kube-proxy stop
service kube-scheduler stop
service kube-controller-manager stop
service kubelet stop
service kube-apiserver stop

#Disable controller-manager for now
#chmod -x /etc/init.d/kube-controller-manager

#Create log folder for Kubernetes services
mkdir /var/log/kubernetes

#Preapre service configs
#sed -i.bkp "s/%%PORTAL_NET%%/$3/g" kube-apiserver.conf

#sed -i.bkp "s/%%MASTER_IP%%/$2/g" kube-proxy.conf

sed -i.bkp "s/%%MASTER_IP%%/$2/g" kube-scheduler.conf
sed -i.bkp "s/%%IP%%/$2/g" kube-scheduler.conf

#sed -i.bkp "s/%%IP%%/$2/g" kubelet.conf


cp -f kube-apiserver.conf /etc/default/kube-apiserver
#cp -f kube-proxy.conf /etc/default/kube-proxy
cp -f kube-scheduler.conf /etc/default/kube-scheduler
#cp -f kubelet.conf /etc/default/kubelet
cp -f kube-controller-manager.conf /etc/default/kube-controller-manager

service kube-apiserver start
service kube-scheduler start
service kube-controller-manager start
#service kubelet start
#service kube-proxy start

/opt/bin/kubectl delete node 127.0.0.1

sleep 1