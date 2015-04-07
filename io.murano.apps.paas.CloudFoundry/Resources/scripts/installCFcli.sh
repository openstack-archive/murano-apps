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

cd /root

wget https://s3.amazonaws.com/go-cli/releases/v6.1.2/cf-cli_amd64.deb
dpkg --install cf-cli_amd64.deb
