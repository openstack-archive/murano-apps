#!/bin/bash
#  Licensed under the Apache License, Version 2.0 (the "License"); you may
#  not use this file except in compliance with the License. You may obtain
#  a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#  WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#  License for the specific language governing permissions and limitations
#  under the License.

SERVER='localhost'

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

sudo sed -e "s/^DBName.*$/DBName=%DATABASE%/" -i /etc/zabbix/zabbix_server.conf
sudo sed -e "s/^DBHost.*$/DBHost=${SERVER}/" -i /etc/zabbix/zabbix_server.conf
sudo sed -e "s/# DBPassword.*$/DBPassword=%PASSWORD%/" -i /etc/zabbix/zabbix_server.conf
sudo sed -e "s/^DBUser.*$/DBUser=%USERNAME%/" -i /etc/zabbix/zabbix_server.conf

cd /usr/share/zabbix-server-mysql/
sudo gunzip *.gz

mysql --user=root --password=root -e "CREATE DATABASE %DATABASE%"
mysql --user=root --password=root -e "CREATE USER '%USERNAME%'@'localhost' IDENTIFIED BY '%PASSWORD%'"
mysql --user=root --password=root -e "GRANT ALL PRIVILEGES ON %DATABASE%.* TO '%USERNAME%'@'localhost' WITH GRANT OPTION"
mysql --user=root --password=root -e "FLUSH PRIVILEGES"

mysql --user=%USERNAME% --password=%PASSWORD% --database=%DATABASE% < schema.sql
mysql --user=%USERNAME% --password=%PASSWORD% --database=%DATABASE% < images.sql
mysql --user=%USERNAME% --password=%PASSWORD% --database=%DATABASE% < data.sql

sudo sed -e "s/^post_max_size.*$/post_max_size = 16M/" -i /etc/php5/apache2/php.ini
sudo sed -e "s/^max_execution_time.*$/max_execution_time = 300/" -i /etc/php5/apache2/php.ini
sudo sed -e "s/^max_input_time.*$/max_input_time = 300/" -i /etc/php5/apache2/php.ini
sudo sed -e "s/;date.timezone.*$/date.timezone = UTC/" -i /etc/php5/apache2/php.ini

sudo cp /usr/share/doc/zabbix-frontend-php/examples/zabbix.conf.php.example /etc/zabbix/zabbix.conf.php

sudo sed -e "s/\$DB\[\"DATABASE\"\].*$/\$DB\[\"DATABASE\"\] = '%DATABASE%';/" -i /etc/zabbix/zabbix.conf.php
sudo sed -e "s/\$DB\[\"USER\"\].*$/\$DB\[\"USER\"\] = '%USERNAME%';/" -i /etc/zabbix/zabbix.conf.php
sudo sed -e "s/\$DB\[\"PASSWORD\"\].*$/\$DB\[\"PASSWORD\"\] = '%PASSWORD%';/" -i /etc/zabbix/zabbix.conf.php
sudo cp /usr/share/doc/zabbix-frontend-php/examples/apache.conf /etc/apache2/conf-available/zabbix.conf
sudo a2enconf zabbix.conf
sudo a2enmod alias
sudo service apache2 restart

sudo sed -e "s/^START=no/START=yes/" -i /etc/default/zabbix-server
sudo iptables -I INPUT 1 -p tcp -m tcp --dport 10051 -j ACCEPT -m comment --comment "by murano, Zabbix"
service zabbix-server restart
