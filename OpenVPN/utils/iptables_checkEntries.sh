#!/bin/sh
sudo iptables -t nat -L | grep openvpn
sudo iptables -L | grep openvpn

