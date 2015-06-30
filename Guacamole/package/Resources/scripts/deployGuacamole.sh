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

# Guacamole version
guac_version=0.9.7
# Tomcat version
tcat_version=7
username="$1"
password="$2"

sudo apt-get update
# Install Packages
sudo apt-get install -y -q make libcairo2-dev libpango-1.0-0 libpango1.0-dev libssh2-1-dev libpng12-dev freerdp-x11 \
                                libssh2-1 libvncserver-dev libfreerdp-dev libvorbis-dev libssl1.0.0 gcc libssh-dev \
                                libpulse-dev libtelnet-dev libossp-uuid-dev
# Download Guacamole Client
sudo wget http://sourceforge.net/projects/guacamole/files/current/binary/guacamole-${guac_version}.war
# Download Guacamole Server
sudo wget http://sourceforge.net/projects/guacamole/files/current/source/guacamole-server-${guac_version}.tar.gz
# Untar the guacamole server source files
sudo tar -xzf guacamole-server-${guac_version}.tar.gz
# Change directory to the source files
cd guacamole-server-${guac_version}/
sudo ./configure --with-init-dir=/etc/init.d
sudo make
sudo make install
sudo update-rc.d guacd defaults
sudo ldconfig
# Create guacamole configuration directory
sudo mkdir /etc/guacamole
# Create guacamole.properties configuration file
sudo cat <<EOF1 > /etc/guacamole/guacamole.properties
basic-user-mapping: /etc/guacamole/user-mapping.xml
EOF1
# Create user-mapping.xml configuration file
sudo cat <<EOF2 > /etc/guacamole/user-mapping.xml
<user-mapping>
    <authorize username="${username}" password="$(echo -n ${password} | md5sum | awk '{print $1}')" encoding="md5">
        <connection name="localhost-ssh">
            <protocol>ssh</protocol>
            <param name="hostname">127.0.0.1</param>
            <param name="port">22</param>
        </connection>
        <connection name="otherhost-vnc">
            <protocol>vnc</protocol>
            <param name="hostname">otherhost</param>
            <param name="port">5901</param>
        </connection>
        <connection name="otherhost-rdp">
            <protocol>rdp</protocol>
            <param name="hostname">otherhost</param>
            <param name="port">3389</param>
        </connection>
    </authorize>
</user-mapping>
EOF2
# Create a new user
sudo useradd -d /etc/guacamole -p $(openssl passwd -1 ${password}) ${username}
# Make guacamole configuration directory readable and writable by the group and others
sudo chmod -R go+rw /etc/guacamole
sudo mkdir /usr/share/tomcat${tcat_version}/.guacamole
# Create a symbolic link of the properties file for Tomcat
sudo ln -s /etc/guacamole/guacamole.properties /usr/share/tomcat${tcat_version}/.guacamole
# Move up a directory to copy the guacamole.war file
cd ..
# Copy the guacamole war file to the Tomcat webapps directory
sudo cp guacamole-${guac_version}.war /var/lib/tomcat${tcat_version}/webapps/guacamole.war
# Start the Guacamole (guacd) service
sudo service guacd start
# Restart Tomcat
sudo service tomcat${tcat_version} restart
