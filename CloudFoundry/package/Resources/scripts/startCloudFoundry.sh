#!/bin/bash

exec &> /tmp/start_cf.log

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
. ~/.profile

cd /root/cf_nise_installer
./scripts/start.sh | tee start.log
/var/vcap/bosh/bin/monit restart cloud_controller_ng
./scripts/start.sh | tee start.log

tail start.log | grep Login

#add_fw_rule '-I INPUT 1 -p tcp -m tcp --dport 8080 -j ACCEPT -m comment --comment "by murano, CloudFoundry"'


