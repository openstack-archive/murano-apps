#!/bin/bash
echo "Deleting a Service" >> /tmp/murano-kube.log
/opt/bin/kubectl delete services $1 >> /tmp/murano-kube.log
