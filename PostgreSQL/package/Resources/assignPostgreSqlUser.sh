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

sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE \"%DATABASE%\" to \"%USER%\""
tee --append /etc/postgresql/*/main/pg_hba.conf <<< "host %DATABASE% %USER% all md5"
sudo /etc/init.d/postgresql restart
