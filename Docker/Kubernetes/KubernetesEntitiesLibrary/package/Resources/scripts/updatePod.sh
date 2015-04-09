#!/bin/bash

#  File with pod is /tmp/pod.json
# $1 new or update

if [ "$1" == "True" ]; then
  #new Pod
  echo "Creating a new Pod" >> /tmp/murano-kube.log
  /opt/bin/kubectl create -f /tmp/pod.json >> /tmp/murano-kube.log
else
  echo "Updating a Pod" >> /tmp/murano-kube.log
  /opt/bin/kubectl update -f /tmp/pod.json >> /tmp/murano-kube.log
fi
