#!/bin/bash

SERVER='localhost'
DB_NAME="$1"
DB_USER="$2"
DB_PASS="$3"

#install requirements

sudo apt-get update

# Mysql server
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'

sudo apt-get -y install mysql-server

# php5, apache2
sudo apt-get -y install apache2 php5 php5-mysql

# Zabbix Server
sudo apt-get -y install zabbix-server-mysql php5-mysql zabbix-frontend-php

# Configure installation

sudo sed -e "s/^DBName.*$/DBName=${DB_NAME}/" -i /etc/zabbix/zabbix_server.conf
sudo sed -e "s/^DBHost.*$/DBHost=${SERVER}/" -i /etc/zabbix/zabbix_server.conf
sudo sed -e "s/# DBPassword.*$/DBPassword=${DB_PASS}/" -i /etc/zabbix/zabbix_server.conf
sudo sed -e "s/^DBUser.*$/DBUser=${DB_USER}/" -i /etc/zabbix/zabbix_server.conf

cd /usr/share/zabbix-server-mysql/
sudo gunzip *.gz

mysql --user=root --password=root -e "CREATE DATABASE ${DB_NAME}"
mysql --user=root --password=root -e "CREATE USER '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}'"
mysql --user=root --password=root -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost' WITH GRANT OPTION"
mysql --user=root --password=root -e "FLUSH PRIVILEGES"

mysql --user=${DB_USER} --password=${DB_PASS} --database=$DB_NAME < schema.sql
mysql --user=${DB_USER} --password=${DB_PASS} --database=$DB_NAME < images.sql
mysql --user=${DB_USER} --password=${DB_PASS} --database=$DB_NAME < data.sql

sudo sed -e "s/^post_max_size.*$/post_max_size = 16M/" -i /etc/php5/apache2/php.ini
sudo sed -e "s/^max_execution_time.*$/max_execution_time = 300/" -i /etc/php5/apache2/php.ini
sudo sed -e "s/^max_input_time.*$/max_input_time = 300/" -i /etc/php5/apache2/php.ini
sudo sed -e "s/;date.timezone.*$/date.timezone = UTC/" -i /etc/php5/apache2/php.ini

sudo cp /usr/share/doc/zabbix-frontend-php/examples/zabbix.conf.php.example /etc/zabbix/zabbix.conf.php

sudo sed -e "s/\$DB\[\"DATABASE\"\].*$/\$DB\[\"DATABASE\"\] = '${DB_NAME}';/" -i /etc/zabbix/zabbix.conf.php
sudo sed -e "s/\$DB\[\"USER\"\].*$/\$DB\[\"USER\"\] = '${DB_USER}';/" -i /etc/zabbix/zabbix.conf.php
sudo sed -e "s/\$DB\[\"PASSWORD\"\].*$/\$DB\[\"PASSWORD\"\] = '${DB_PASS}';/" -i /etc/zabbix/zabbix.conf.php
sudo cp /usr/share/doc/zabbix-frontend-php/examples/apache.conf /etc/apache2/conf-available/zabbix.conf
sudo a2enconf zabbix.conf
sudo a2enmod alias
sudo service apache2 restart

sudo sed -e "s/^START=no/START=yes/" -i /etc/default/zabbix-server
sudo iptables -I INPUT 1 -p tcp -m tcp --dport 10051 -j ACCEPT -m comment --comment "by murano, Zabbix"
service zabbix-server restart
