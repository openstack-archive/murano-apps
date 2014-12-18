#!/bin/bash

# VARIABLES

SERVER="$1"
HOSTNAME="$2"

sudo apt-get update

sudo apt-get -y install zabbix-agent

sudo sed -e "s/^Server.*$/Server=${SERVER}/" -i /etc/zabbix/zabbix_agentd.conf
sudo sed -e "s/^# ServerActive.*$/ServerActive=${SERVER}/" -i /etc/zabbix/zabbix_agentd.conf
sudo sed -e "s/^Hostname.*$/Hostname=${HOSTNAME}/" -i /etc/zabbix/zabbix_agentd.conf
sudo sed -e "s/^# EnableRemoteCommands.*$/EnableRemoteCommands=1/" -i /etc/zabbix/zabbix_agentd.conf

sudo service zabbix-agent restart
