#!/bin/bash

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
