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

exec &> /tmp/deploy_diego_release.log

function include(){
    curr_dir=$(cd "$(dirname "${0}")" && pwd)
    inc_file_path=$curr_dir/$1
    if [ -f "$inc_file_path" ]; then
        . "${inc_file_path}"
    else
        echo -e "$inc_file_path not found!"
        exit 1
    fi
}
include "common.sh"

BOSH_UUID=$(bosh status --uuid)
sed -i "s/__director_uuid__/${BOSH_UUID}/g" /root/workspace/diego.yml
bosh deployment /root/workspace/diego.yml
retry 3 bosh -n deploy --recreate

