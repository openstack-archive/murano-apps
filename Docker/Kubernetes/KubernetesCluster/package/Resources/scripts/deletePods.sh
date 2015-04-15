#!/bin/bash
echo "Deleting Pods" >> /tmp/murano-kube.log
/opt/bin/kubectl delete pod -l $1 >> /tmp/murano-kube.log
