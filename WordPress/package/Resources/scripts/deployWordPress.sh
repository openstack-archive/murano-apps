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

# Install tools for deploying
sudo apt-get update
sudo apt-get -y -q install unzip
sudo apt-get -y -q install php5-mysql
sudo apt-get -y -q install mysql-client
 
# Install Wordpress
wget http://wordpress.org/latest.zip
sudo unzip -q latest.zip -d /var/www/html/
sudo chown -R www-data.www-data /var/www/html/wordpress
sudo chmod -R 755 /var/www/html/wordpress
sudo mkdir -p /var/www/html/wordpress/wp-content/uploads
sudo chown -R :www-data /var/www/html/wordpress/wp-content/uploads
cd /var/www/html/wordpress/
sudo cp wp-config-sample.php wp-config.php
