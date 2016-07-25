#!/bin/bash

deploy() {
set -x
# Configure the APT software source.
echo 'deb http://repo.cw-ngv.com/stable binary/' > /etc/apt/sources.list.d/clearwater.list
curl -L http://repo.cw-ngv.com/repo_key | apt-key add -
apt-get update
# Configure /etc/clearwater/local_config.
mkdir -p /etc/clearwater
etcd_ip=%PRIVATE_IP%
cat > /etc/clearwater/local_config << EOF
local_ip=%PRIVATE_IP%
public_ip=%PUBLIC_IP%
public_hostname=ellis-0.%ZONE%
etcd_cluster=$etcd_ip
EOF
# Now install the software.
DEBIAN_FRONTEND=noninteractive apt-get install ellis --yes --force-yes
DEBIAN_FRONTEND=noninteractive apt-get install clearwater-config-manager --yes --force-yes
# Wait until etcd is up and running before uploading the shared_config
/usr/share/clearwater/clearwater-etcd/scripts/wait_for_etcd
# Configure and upload /etc/clearwater/shared_config.
cat > /etc/clearwater/shared_config << EOF
# Deployment definitions
home_domain=%ZONE%
sprout_hostname=sprout.%ZONE%
hs_hostname=hs.%ZONE%:8888
hs_provisioning_hostname=hs-prov.%ZONE%:8889
ralf_hostname=ralf.%ZONE%:10888
xdms_hostname=homer.%ZONE%:7888

upstream_port=0
# Email server configuration
smtp_smarthost=localhost
smtp_username=username
smtp_password=password
email_recovery_sender=clearwater@example.org

# Keys
signup_key=secret
turn_workaround=secret
ellis_api_key=secret
ellis_cookie_key=secret
EOF
sudo /usr/share/clearwater/clearwater-config-manager/scripts/upload_shared_config
# Tweak /etc/clearwater/shared_config to use homer's management hostname instead of signaling.
# This works around https://github.com/Metaswitch/ellis/issues/153.
sed -e 's/^xdms_hostname=.*$/xdms_hostname=homer-0.%ZONE%:7888/g' -i /etc/clearwater/shared_config
service clearwater-infrastructure restart
service ellis stop
# Allocate a allocate a pool of numbers to assign to users.
/usr/share/clearwater/ellis/env/bin/python /usr/share/clearwater/ellis/src/metaswitch/ellis/tools/create_numbers.py --start 6505550000 --count 1000 --realm %ZONE%
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
update add ellis-0.%ZONE%. 30 $(ip2rr %PUBLIC_IP%)
update add ellis.%ZONE%. 30 $(ip2rr %PUBLIC_IP%)
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
deploy 2>&1 | tee -a /var/log/clearwater-ellis.log
