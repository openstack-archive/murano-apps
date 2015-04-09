#!/bin/bash
if [ "$1" == "True" ]; then
  echo "Creating a new Replication Controller" >> /tmp/murano-kube.log
  /opt/bin/kubectl create -f /tmp/controller.json >> /tmp/murano-kube.log
else
  echo "Updating a Replication Controller" >> /tmp/murano-kube.log
  /opt/bin/kubectl update -f /tmp/controller.json >> /tmp/murano-kube.log
fi
