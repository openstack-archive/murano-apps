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

sudo sed -e "s/^bind_ip*/#bind_ip/" -i /etc/mongodb.conf
sudo service mongodb restart

# When the MongoDB is launched for the first time,
# it will initialize journal and preallocate the journal files.
# These initializations will be executed in the background.
# The MongoDB service can only be connected by clients
# after these initializations. So this step is trying most 20 times
# to test the connection with the MongoDB service,
# and there is a 30 seconds interval every time.
count=20

while [ $count -gt 0 ]; do
sudo mongo <<EOF
    exit
EOF
    if [ $? -eq 0 ]; then
        exit 0
    fi
    count=$((count - 1))
    sleep 30
done
exit 1
