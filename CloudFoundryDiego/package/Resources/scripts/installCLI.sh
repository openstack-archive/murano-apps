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

set -eu

exec &> /tmp/install_cli.log

wget "https://cli.run.pivotal.io/stable?release=linux64-binary&source=github" -O /tmp/cf-cli.tgz
tar xf /tmp/cf-cli.tgz -C /tmp
mv /tmp/cf /usr/local/bin/
rm /tmp/cf-cli.tgz

cf add-plugin-repo CF-Community http://plugins.cloudfoundry.org/ || true
cf install-plugin Diego-Beta -r CF-Community

cf login -a api.10.244.0.34.xip.io -u admin -p admin --skip-ssl-validation
cf create-org diego
cf target -o diego
cf create-space diego
cf target -s diego
