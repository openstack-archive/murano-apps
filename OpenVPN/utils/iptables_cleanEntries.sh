#!/bin/bash
ip=`bash iptables_checkEntries.sh  | tail -n1  | tr -s " " | cut -d " " -f 5`
echo $ip
sudo iptables -t nat -D PREROUTING -p udp -i eth0 --dport 1194 -j DNAT --to-destination $ip:1194
sudo iptables -D FORWARD -p udp -d $ip --dport 1194 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT

