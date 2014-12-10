#!/bin/bash

sudo sed -e "s/define('DB_NAME'.*$/define('DB_NAME', '$1');/" -i /var/www/html/wordpress/wp-config.php
sudo sed -e "s/define('DB_USER'.*$/define('DB_USER', '$2');/" -i /var/www/html/wordpress/wp-config.php
sudo sed -e "s/define('DB_PASSWORD'.*$/define('DB_PASSWORD', '$3');/" -i /var/www/html/wordpress/wp-config.php
sudo sed -e "s/define('DB_HOST'.*$/define('DB_HOST', '$4');/" -i /var/www/html/wordpress/wp-config.php

sudo service apache2 restart
