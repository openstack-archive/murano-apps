#!/bin/bash

sudo apt-get update

sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'

sudo apt-get -y -q install mysql-server
sed -e "s/^bind-address*/#bind-address/" -i /etc/mysql/my.cnf
service mysql restart

sudo iptables -I INPUT 1 -p tcp -m tcp --dport 3306 -j ACCEPT -m comment --comment "by murano, MySQL"
