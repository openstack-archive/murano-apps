#!/bin/bash
#
# Copyright 2015 Oracle and/or its affiliates. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
. ./ora_env.sh

# lsnrctl is the proper way to get the host and port numbers.
# Get the descriptions but only the tcp and tcps descriptions
ip_addrs=`lsnrctl status | grep 'DESCRIPTION.*PROTOCOL=tcp' | sed 's|.*HOST=\([^)]*\))(PORT=\([^)]*\).*|\1:\2|g'`
for addr in $ip_addrs
do
    tnsping $addr >> /dev/null
    if [  $? -eq 0 ]
    then
        echo "$addr"
        break
    else
        echo "No Listener"
    fi
done
