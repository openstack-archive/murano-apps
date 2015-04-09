#!/bin/bash

exec &> /tmp/install_cf_release.log

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

if [ ! -e /tmp/wagrant-reboot ] ; then
  cd /root/cf_nise_installer
  retry 3 ./scripts/install_cf_release.sh
  touch /tmp/wagrant-reboot
  reboot
fi

