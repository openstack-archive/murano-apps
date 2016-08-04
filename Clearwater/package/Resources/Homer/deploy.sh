#!/bin/bash

deploy() {

# Log all output to file.
exec > >(tee -a /var/log/clearwater-homer.log) 2>&1
set -x
# Configure the APT software source.
echo 'deb http://repo.cw-ngv.com/archive/repo101 binary/' > /etc/apt/sources.list.d/clearwater.list
curl -L http://repo.cw-ngv.com/repo_key | apt-key add -
apt-get update
# Configure /etc/clearwater/local_config.
mkdir -p /etc/clearwater
etcd_ip=%ETCD_IP%
[ -n "$etcd_ip" ] || etcd_ip=%PRIVATE_IP%
cat > /etc/clearwater/local_config << EOF
management_local_ip=%PRIVATE_IP%
local_ip=%PRIVATE_IP%
public_ip=%PUBLIC_IP%
public_hostname=homer-%INDEX%.%ZONE%
etcd_cluster=$etcd_ip
EOF

# Now install the software.
DEBIAN_FRONTEND=noninteractive apt-get install clearwater-cassandra --yes --force-yes
DEBIAN_FRONTEND=noninteractive apt-get install homer --yes --force-yes
DEBIAN_FRONTEND=noninteractive apt-get install clearwater-management --yes --force-yes
}

# Log all output to file.
deploy 2>&1 | tee -a /var/log/clearwater-homer.log
