#!/bin/bash
ADDR=`ip addr show eth0 | grep 'inet ' | cut -d' ' -f 6 | cut -d'/' -f1`
DOCKER_OPTS="-H $ADDR:2375"

sudo docker $DOCKER_OPTS pull $1
