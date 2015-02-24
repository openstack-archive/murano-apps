#!/bin/bash

# $1 - NAME
# $2 - IP
# $3 - MASTER_IP

if [ "$3" != "$2" ]; then
 service kube-proxy stop
 service kube-scheduler stop
 service kube-controller-manager stop
 service kubelet stop
 service kube-apiserver stop

 #Disable managmenets services on a minion
 chmod -x /etc/init.d/kube-controller-manager
 chmod -x /etc/init.d/kube-apiserver
 chmod -x /etc/init.d/kube-scheduler
else
 service kube-proxy stop
 service kubelet stop
fi
#Create log folder for Kubernetes services
mkdir /var/log/kubernetes

#Preapre service configs

sed -i.bkp "s/%%MASTER_IP%%/$3/g" kube-proxy.conf

#sed -i.bkp "s/%%MASTER_IP%%/$3/g" kube-scheduler.conf
#sed -i.bkp "s/%%IP%%/$2/g" kube-scheduler.conf
sed -i.bkp "s/%%IP%%/$2/g" kubelet.conf


cp -f kube-proxy.conf /etc/default/kube-proxy
cp -f kubelet.conf /etc/default/kubelet


service kubelet start
service kube-proxy start

sleep 1