#!/bin/bash

#  File with pod is /tmp/pod.json
# $1 new or update
DEFINITION_DIR=/var/run/murano-kubernetes
mkdir -p $DEFINITION_DIR

podId=$2
kind=$3
fileName=$4
echo "$podId $kind $fileName" >> $DEFINITION_DIR/elements.list

if [ "$1" == "True" ]; then
  #new Pod
  echo "Creating a new Pod" >> /tmp/murano-kube.log
  /opt/bin/kubectl create -f $fileName >> /tmp/murano-kube.log
else
  echo "Updating a Pod" >> /tmp/murano-kube.log
  /opt/bin/kubectl update -f $fileName >> /tmp/murano-kube.log
fi
