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

exec &> /tmp/install_bosh.log

function include(){
    curr_dir=$(cd $(dirname "$0") && pwd)
    inc_file_path=$curr_dir/$1
    if [ -f "$inc_file_path" ]; then
        . $inc_file_path
    else
        echo -e "$inc_file_path not found!"
        exit 1
    fi
}
include "common.sh"

mkdir -p /root/workspace
install -D -g root -o root -m 0644 config.json /root/workspace
install -D -g root -o root -m 0644 manifest.yaml /root/workspace

IP=$(ip addr | grep 'inet .*global' | cut -f 6 -d ' ' | cut -f1 -d '/' | head -n 1)
sed -i "s/_local_ip_/$IP/g" /root/workspace/manifest.yaml

apt-get update
apt-get -o Dpkg::Options::="--force-confnew" -y install git build-essential ruby ruby-dev libxml2-dev libsqlite3-dev libxslt1-dev libpq-dev libmysqlclient-dev

cd /root/workspace
git clone https://github.com/cppforlife/bosh-provisioner
cd /root/workspace/bosh-provisioner
git checkout 82fd27a53a6a049908293d7de9bf89c22ec941cd
retry 3 ./assets/bosh-provisioner -configPath=/root/workspace/config.json

(cat <<BOSH_CONFIG
target: https://127.0.0.1:25555
auth:
  https://127.0.0.1:25555:
    username: admin
    password: admin
BOSH_CONFIG
) > $HOME/.bosh_config

bosh target 127.0.0.1

