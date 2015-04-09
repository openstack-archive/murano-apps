#!/bin/bash

#  File with service is /tmp/service.json
# $1 new or update
DEFINITION_DIR=/var/run/murano-kubernetes
mkdir -p $DEFINITION_DIR
serviceId=$2
kind=$3
fileName=$4

echo "$serviceId $kind $fileName" >> $DEFINITION_DIR/elements.list

if [ "$1" == "True" ]; then
  echo "Creating a new Service" >> /tmp/murano-kube.log
  /opt/bin/kubectl create -f $fileName >> /tmp/murano-kube.log
else
  echo "Updating a Service" >> /tmp/murano-kube.log
  /opt/bin/kubectl update -f $fileName >> /tmp/murano-kube.log
fi
