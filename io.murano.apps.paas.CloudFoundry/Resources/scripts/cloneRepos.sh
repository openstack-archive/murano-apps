#!/bin/bash

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

cd /root/cf_nise_installer

bash ./scripts/clone_nise_bosh.sh >> install.log
bash ./scripts/clone_cf_release.sh >> install.log
