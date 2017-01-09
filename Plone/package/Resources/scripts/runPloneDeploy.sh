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

PL_PATH="$1"
PL_PASS="$2"
PL_PORT="$3"

# Write log. Redirect stdout & stderr into log file:
exec &> /var/log/runPloneDeploy.log

# echo "Installing all packages."
sudo apt-get update

# Install the operating system software and libraries needed to run Plone:
sudo apt-get -y install python-setuptools python-dev build-essential libssl-dev libxml2-dev libxslt1-dev libbz2-dev libjpeg62-dev

# Install optional system packages for the handling of PDF and Office files. Can be omitted:
sudo apt-get -y install libreadline-dev wv poppler-utils

# Download the latest Plone unified installer:
wget --no-check-certificate https://launchpad.net/plone/5.0/5.0.4/+download/Plone-5.0.4-UnifiedInstaller.tgz

# Unzip the latest Plone unified installer:
tar -xvf Plone-5.0.4-UnifiedInstaller.tgz
cd Plone-5.0.4-UnifiedInstaller

# Set the port that Plone will listen to on available network interfaces. Editing "http-address" param in buildout.cfg file:
sed -i "s/^http-address = [0-9]*$/http-address = ${PL_PORT}/" buildout_templates/buildout.cfg

# Run the Plone installer in standalone mode
./install.sh --password="${PL_PASS}" --target="${PL_PATH}" standalone

# Start Plone
cd "${PL_PATH}/zinstance"
bin/plonectl start
