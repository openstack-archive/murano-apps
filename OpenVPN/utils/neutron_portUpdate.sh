#!/bin/bash

if [ "$#" -ne 1 ]; then
  echo "Usage: bash $0 <SERVERNAME>" >&2
  exit 1
fi

source ~/devstack/openrc admin admin

id=`neutron port-list | grep $1 | cut -d " " -f 2`
echo "port id: $id"
neutron port-update $id --port_security-enabled=False

