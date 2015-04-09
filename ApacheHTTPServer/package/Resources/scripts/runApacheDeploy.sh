#!/bin/bash

sudo apt-get update
sudo apt-get -y install apache2

if [[ $1 == "True" ]];
then
    sudo apt-get -y install php5
fi

sudo iptables -I INPUT 1 -p tcp -m tcp --dport 443 -j ACCEPT -m comment --comment "by murano, Apache server access on HTTPS port 443"
sudo iptables -I INPUT 1 -p tcp -m tcp --dport 80 -j ACCEPT -m comment --comment "by murano, Apache server access on HTTP port 80"
