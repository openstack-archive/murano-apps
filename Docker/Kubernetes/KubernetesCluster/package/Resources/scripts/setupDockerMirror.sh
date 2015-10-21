#!/bin/bash

source /etc/default/docker
DOCKER_OPTS+=" --registry-mirror=$1"
echo DOCKER_OPTS=\"$DOCKER_OPTS\" > /etc/default/docker