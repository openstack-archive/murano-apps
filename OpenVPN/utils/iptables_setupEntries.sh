#!/bin/bash

if [ "$#" -ne 1 ]; then
  echo "Usage: bash $0 <server_floatingIP> " >&2
  exit 1
fi

sudo iptables -t nat -A PREROUTING -p udp -i eth0 --dport 1194 -j DNAT --to-destination $1:1194
sudo iptables -A FORWARD -p udp -d $1 --dport 1194 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT

