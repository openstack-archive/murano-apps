#!/bin/bash

deploy() {
# Log all output to file.
exec > >(tee -a /var/log/clearwater-homer.log) 2>&1
set -x
# Configure the APT software source.
echo 'deb http://repo.cw-ngv.com/stable binary/' > /etc/apt/sources.list.d/clearwater.list
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
public_hostname=homer-0.%ZONE%
etcd_cluster=$etcd_ip
EOF
# Now install the software.
DEBIAN_FRONTEND=noninteractive apt-get install clearwater-cassandra --yes --force-yes
DEBIAN_FRONTEND=noninteractive apt-get install homer --yes --force-yes
DEBIAN_FRONTEND=noninteractive apt-get install clearwater-management --yes --force-yes
# Function to give DNS record type and IP address for specified IP address
ip2rr() {
if echo "$1" | grep -q -e '[^0-9.]' ; then
echo AAAA "$1"
else
echo A "$1"
fi
}
# Update DNS
retries=0
while ! { nsupdate -y "%ZONE%:%DNSSEC_KEY%" -v << EOF
server %DNS_PRIVATE_IP%
update add homer-0.%ZONE%. 30 $(ip2rr %PUBLIC_IP%)
update add homer.%ZONE%. 30 $(ip2rr %PUBLIC_IP%)
send
EOF
} && [ $retries -lt 10 ]
do
retries=$((retries + 1))
echo 'nsupdate failed - retrying (retry '$retries')...'
sleep 5
done
# Use the DNS server.
echo 'nameserver %DNS_PRIVATE_IP%' > /etc/dnsmasq.resolv.conf
echo 'RESOLV_CONF=/etc/dnsmasq.resolv.conf' >> /etc/default/dnsmasq
service dnsmasq force-reload
}

# Log all output to file.
deploy 2>&1 | tee -a /var/log/clearwater-homer.log
