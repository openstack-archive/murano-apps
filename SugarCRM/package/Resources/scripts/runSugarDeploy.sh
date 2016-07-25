#!/bin/bash

# SugarCRM Community Edition is a customer relationship management program developed by
# SugarCRM, Inc. Copyright (C) 2004-2013 SugarCRM Inc.
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of the GNU Affero General Public License version 3 as published by the
# Free Software Foundation with the addition of the following permission added
# to Section 15 as permitted in Section 7(a): FOR ANY PART OF THE COVERED WORK
# IN WHICH THE COPYRIGHT IS OWNED BY SUGARCRM, SUGARCRM DISCLAIMS THE WARRANTY
# OF NON INFRINGEMENT OF THIRD PARTY RIGHTS.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more
# details.
#
# You should have received a copy of the GNU Affero General Public License along with
# this program; if not, see http://www.gnu.org/licenses or write to the Free
# Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
# 02110-1301 USA.
#
# You can contact SugarCRM, Inc. headquarters at 10050 North Wolfe Road,
# SW2-130, Cupertino, CA 95014, USA. or at email address contact@sugarcrm.com.
#
# The interactive user interfaces in modified source and object code versions
# of this program must display Appropriate Legal Notices, as required under
# Section 5 of the GNU Affero General Public License version 3.
#
# In accordance with Section 7(b) of the GNU Affero General Public License version 3,
# these Appropriate Legal Notices must retain the display of the "Powered by
# SugarCRM" logo. If the display of the logo is not reasonably feasible for
# technical reasons, the Appropriate Legal Notices must display the words
# "Powered by SugarCRM".

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

