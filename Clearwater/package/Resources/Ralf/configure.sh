#!/bin/bash

configure() {
set -x
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
update add ralf-%INDEX%.%ZONE%. 30 $(ip2rr %PUBLIC_IP%)
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
configure 2>&1|tee -a /var/log/clearwater-ralf.log
