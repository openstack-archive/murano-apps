#!/bin/bash

# $1 - NAME
# $2 - IP
# $3 - ETCD_INITIAL_CLUSTER

chmod +x ./member-etcd-setup.sh

./member-etcd-setup.sh $1 $2 $3  2>&1 | tee /tmp/member-etcd-setup.log