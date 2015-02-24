#!/bin/bash
if [ "$1" == "True" ]; then
  echo "Creating a new Service" >> /tmp/murano-kube.log
  /opt/bin/kubectl create -f /tmp/service.json >> /tmp/murano-kube.log
else
  echo "Updating a Service" >> /tmp/murano-kube.log
  /opt/bin/kubectl update -f /tmp/service.json >> /tmp/murano-kube.log
fi
