#!/bin/bash
echo "Deleting a replication controller" >> /tmp/murano-kube.log
/opt/bin/kubectl delete replicationcontrollers $1 >> /tmp/murano-kube.log
