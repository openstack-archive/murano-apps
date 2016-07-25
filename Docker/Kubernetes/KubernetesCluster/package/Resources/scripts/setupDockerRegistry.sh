#!/bin/bash

source /etc/default/docker
DOCKER_OPTS+=" --insecure-registry $1"
echo "DOCKER_OPTS=${DOCKER_OPTS}" > /etc/default/docker
