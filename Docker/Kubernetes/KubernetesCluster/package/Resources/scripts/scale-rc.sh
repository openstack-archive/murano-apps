#!/bin/bash

# $1 - RC name
# $2 - new size

/opt/bin/kubectl scale rc $1 --replicas=$2
