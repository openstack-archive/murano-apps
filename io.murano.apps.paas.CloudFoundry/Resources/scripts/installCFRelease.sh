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
. ~/.profile

if [ ! -e /tmp/wagrant-reboot ] ; then
log "DEBUG: change dir to cf_nise_installer"

cd /root/cf_nise_installer

log "Debug: Starting cf-release script"
pwd >> current.log

./scripts/install_cf_release.sh >> install.log
 touch /tmp/wagrant-reboot
 reboot
fi

