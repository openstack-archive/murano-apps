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

exec &> /tmp/upload_releases.log

function include(){
    curr_dir=$(cd "$(dirname "$0")" && pwd)
    inc_file_path=$curr_dir/$1
    if [ -f "$inc_file_path" ]; then
        . "${inc_file_path}"
    else
        echo -e "$inc_file_path not found!"
        exit 1
    fi
}
include "common.sh"

cd /tmp
IMAGE=$(bosh public stemcells | grep "bosh-stemcell-.*-warden-boshlite-ubuntu-trusty-go_agent.tgz" | head -n1 | awk '{print $2}')
bosh download public stemcell "${IMAGE}"
bosh upload stemcell "${IMAGE}"
rm -f "${IMAGE}"

retry 3 bosh -n upload release /root/workspace/cf-release.tgz
retry 3 bosh -n upload release /root/workspace/diego-release.tgz

rm -f /root/workspace/cf-release.tgz
rm -f /root/workspace/diego-release.tgz
