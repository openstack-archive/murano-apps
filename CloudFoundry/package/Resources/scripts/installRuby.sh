#!/bin/bash

exec &> /tmp/install_ruby.log

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

apt-get update
apt-get install -y curl git wget

sed -i 's/^mesg n$/tty -s \&\& mesg n/g' /root/.profile

cd /root
git clone https://github.com/yudai/cf_nise_installer.git

cd /root/cf_nise_installer
retry 3 ./scripts/install_ruby.sh
