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

apt-get update
apt-get -y -q install unzip
apt-get -y -q install php5-mysql
apt-get -y -q install mysql-client

systemctl restart apache2

wget -O sugar.zip https://www.dropbox.com/s/jlaabqamwj8hjcg/sugar.zip?dl=0
sudo unzip -q sugar.zip -d /var/www/html/
sudo chown -R www-data.www-data /var/www/html/Sugar
sudo chmod -R 755 /var/www/html/Sugar

sed -i.bkp "s/%%DB_HOST%%/$1/g; s/%%DB_NAME%%/$2/g; s/%%ADMIN_NAME%%/$3/g; s/%%ADMIN_PASSWORD%%/$4/g; s/%%DB_USER%%/$5/g; s/%%DB_PASSWORD%%/$6/g; s/%%HOST%%/$7/g; s/%%DEMO_DATA%%/$8/g" config_si.php

cp config_si.php /var/www/html/Sugar/

curl -v "http://localhost/Sugar/install.php?goto=SilentInstall&cli=true"

