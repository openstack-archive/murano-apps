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

# $1 = server/agent

function add_repo {
  OS=$1
  if [ "$OS" == "rhel" ]; then
    echo "
[gocd]
name     = GoCD YUM Repository
baseurl  = https://download.go.cd
enabled  = 1
gpgcheck = 1
gpgkey   = https://download.go.cd/GOCD-GPG-KEY.asc
" | sudo tee /etc/yum.repos.d/gocd.repo
  elif [ "$OS" == "debian" ]; then
    echo "deb https://download.go.cd /" | sudo tee /etc/apt/sources.list.d/gocd.list
    curl https://download.go.cd/GOCD-GPG-KEY.asc | sudo apt-key add -
    sudo apt-get update
  fi
}

function install_gocd_agent {
  OS=$1
  if [ "$OS" == "rhel" ]; then
    sudo mkdir /var/go
    sudo yum install -y java-1.7.0-openjdk go-agent
  elif [ "$OS" == "debian" ]; then
    sudo apt-get install -y go-agent
  fi
}

function install_gocd_server {
  OS=$1
  if [ "$OS" == "rhel" ]; then
    sudo mkdir /var/go
    sudo yum install -y java-1.7.0-openjdk go-server
  elif [ "$OS" == "debian" ]; then
    sudo apt-get install -y go-server
  fi
}

if [ -f "/etc/redhat-release" ]; then
  OS="rhel"
elif [ -f "/etc/lsb-release" ]; then
  OS="debian"
else
  OS="unknown"
fi

add_repo $OS

if [ "$1" == "server" ]; then
  install_gocd_server $OS
elif [ "$1" == "agent" ]; then
  install_gocd_agent $OS
else
  echo "Unknown node role"
fi
