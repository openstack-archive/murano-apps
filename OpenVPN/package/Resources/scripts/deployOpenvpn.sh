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
#$1 - tapDhcpBegin
#$2 - tapDhcpEnd
#$3 - netmask
#$4 - gceUserName
#$5 - gcePassword
#$6 - gceNodesIp
#$7 - publicServerPort
#$8 - publicServerIp
# $9 - instance name
# $10 - environment name
# $11 - OPENSTACK_IP
# $12 - tenant
# $13 - username
# $14 - password

openvpn_conf="/etc/os_openvpn/os_openvpn.conf"
mkdir -p /etc/os_openvpn
sudo touch ${openvpn_conf}
echo "[DEFAULT]" >> ${openvpn_conf}
echo "TAP_DHCP_BEGIN=${1}" >> ${openvpn_conf}
echo "TAP_DHCP_END=${2}" >> ${openvpn_conf}
echo "netmask=${3}" >> ${openvpn_conf}
echo " " >> ${openvpn_conf}
echo "[GCE]" >> ${openvpn_conf}
echo "gceUserName=${4}" >> ${openvpn_conf}
echo "gcePassword=${5}" >> ${openvpn_conf}
echo "gceNodesIp=${6}" >> ${openvpn_conf}
echo "publicServerPort=${7}" >> ${openvpn_conf}
echo "publicServerIp=${8}" >> ${openvpn_conf}
echo " " >> ${openvpn_conf}
echo "[INSTANCE]" >> ${openvpn_conf}
echo "instanceName=${9}" >> ${openvpn_conf}
echo "envName=${10}" >> ${openvpn_conf}
echo "OPENSTACK_IP=${11}" >> ${openvpn_conf}
echo "tenant=${12}" >> ${openvpn_conf}
echo "username=${13}" >> ${openvpn_conf}
echo "password=${14}" >> ${openvpn_conf}

mkdir -p /opt/openvpn
mkdir -p /opt/openvpn/templates
cp openvpn/client.sh /opt/openvpn
cp openvpn/server.sh /opt/openvpn
cp openvpn/portDisable.py /opt/openvpn
cp openvpn/templates/client.conf /opt/openvpn/templates
cp openvpn/templates/down.sh /opt/openvpn/templates
cp openvpn/templates/interfaces /opt/openvpn/templates
cp openvpn/templates/server.conf /opt/openvpn/templates
cp openvpn/templates/up.sh /opt/openvpn/templates

bash /opt/openvpn/server.sh >> /tmp/openvpn-server.log
bash /opt/openvpn/client.sh >> /tmp/openvpn-client.log
python /opt/openvpn/portDisable.py >> /tmp/openvpn-port.log

