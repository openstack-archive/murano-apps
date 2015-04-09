#!/bin/bash
echo "Deleting a Minion" >> /tmp/murano-kube.log
/opt/bin/kubectl delete node $1 >> /tmp/murano-kube.log
