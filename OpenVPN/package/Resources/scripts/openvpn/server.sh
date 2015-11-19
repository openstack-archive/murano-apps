#!/bin/bash -x

set -e
conf_file="/etc/os_openvpn/os_openvpn.conf"
TAP_DHCP_BEGIN=$(awk -F "=" '/^TAP_DHCP_BEGIN/ {print $2}' $conf_file)
TAP_DHCP_END=$(awk -F "=" '/^TAP_DHCP_END/ {print $2}' $conf_file)
netmask=$(awk -F "=" '/^netmask/ {print $2}' $conf_file)

sudo apt-get update
sudo apt-get install -y openvpn bridge-utils easy-rsa sshpass
HARDWARE_ADDR=`sudo ifconfig eth0 | grep -o -E '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}'`
sudo sed -i.bkp "s/%%HARDWARE_ADDR%%/$HARDWARE_ADDR/g" /opt/openvpn/templates/interfaces
sudo cp /opt/openvpn/templates/interfaces /etc/network/interfaces
sudo sleep 2
sudo ifup br0
sudo sleep 5
sudo sed -i -e 's/^#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
sudo sysctl -p /etc/sysctl.conf

# Configuring OpenVPN Bridge Server Certificates
sudo rm -rf /etc/openvpn/easy-rsa/
sudo make-cadir /etc/openvpn/easy-rsa/
sudo chmod -R 777 /etc/openvpn/easy-rsa
cd /etc/openvpn/easy-rsa/
source ./vars
./clean-all
./build-dh
./pkitool --initca
./pkitool --server server
cd keys
openvpn --genkey --secret ta.key
sudo cp server.crt server.key ca.crt dh2048.pem ta.key ../../

sudo cp /opt/openvpn/templates/up.sh /etc/openvpn/up.sh
sudo cp /opt/openvpn/templates/down.sh /etc/openvpn/down.sh
sudo chmod 777 /etc/openvpn/up.sh /etc/openvpn/down.sh
server=`sudo ifconfig br0 | grep "inet addr" | cut -d ':' -f 2 | cut -d ' ' -f 1`
sudo sed -ie s/BRIDGE_IP/${server}/ /opt/openvpn/templates/server.conf
sudo sed -ie s/BRIDGE_NETMASK/${netmask}/ /opt/openvpn/templates/server.conf
sudo sed -ie s/BRIDGE_START_TAP_IP/${TAP_DHCP_BEGIN}/ /opt/openvpn/templates/server.conf
sudo sed -ie s/BRIDGE_END_TAP_IP/${TAP_DHCP_END}/ /opt/openvpn/templates/server.conf
sudo cp /opt/openvpn/templates/server.conf /etc/openvpn/server.conf
sudo service openvpn start

