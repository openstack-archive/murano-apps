#!/bin/bash

ADDR=`ip addr show eth0 | grep 'inet ' | cut -d' ' -f 6 | cut -d'/' -f1`
sudo echo "DOCKER_OPTS=\"-H $ADDR:2375\"" >> /etc/default/docker

sudo service docker restart

