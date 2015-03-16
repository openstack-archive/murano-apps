#!/bin/bash

# $1 - NAME
# $2 - IP
#

sed -i.bkp "s/%%NAME%%/$1/g" minion-node.json
sed -i.bkp "s/%%IP%%/$2/g" minion-node.json

/opt/bin/kubectl create -f minion-node.json
