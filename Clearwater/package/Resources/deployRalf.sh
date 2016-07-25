#!/bin/bash

deploy() {
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
public_ip=%PRIVATE_IP%
public_hostname=ralf-0.%ZONE%
etcd_cluster=$etcd_ip
EOF
# Create /etc/chronos/chronos.conf.
mkdir -p /etc/chronos
cat > /etc/chronos/chronos.conf << EOF
[http]
bind-address = %PRIVATE_IP%
bind-port = 7253
threads = 50
[logging]
folder = /var/log/chronos
level = 2
[alarms]
enabled = true
[exceptions]
max_ttl = 600
EOF
# Now install the software.
DEBIAN_FRONTEND=noninteractive apt-get install ralf --yes --force-yes
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
update add ralf-0.%ZONE%. 30 $(ip2rr %PUBLIC_IP%)
update add ralf.%ZONE%. 30 $(ip2rr %PRIVATE_IP%)
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
deploy 2>&1 | tee -a /var/log/clearwater-ralf.log
