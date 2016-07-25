#!/bin/bash

deploy () {
    set -x

    # Install BIND.
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install bind9 --yes

    # Update BIND configuration with the specified zone and key.
    cat >> /etc/bind/named.conf.local << EOF
key %ZONE%. {
  algorithm "HMAC-MD5";
  secret "%DNSSEC_KEY%";
};

zone "%ZONE%" IN {
  type master;
  file "/var/lib/bind/db.%ZONE%";
  allow-update {
    key %ZONE%.;
  };
};
EOF

    # Function to give DNS record type and IP address for specified IP address
    ip2rr() {
      if echo "${1}" | grep -q -e '[^0-9.]' ; then
        echo AAAA "${1}"
      else
        echo A "${1}"
      fi
    }

    # Create basic zone configuration.
    cat > /var/lib/bind/db.%ZONE% << EOF
\$ORIGIN %ZONE%.
\$TTL 1h
@ IN SOA ns admin\@%ZONE%. ( $(date +%Y%m%d%H) 1d 2h 1w 30s )
@ NS ns
ns $(ip2rr %PUBLIC_IP%)
EOF
    chown root:bind /var/lib/bind/db.%ZONE%

    # Now that BIND configuration is correct, kick it to reload.
    service bind9 reload
}

# Log all output to file.
deploy 2>&1 | tee -a /var/log/bind-install.log
