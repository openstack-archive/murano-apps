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

set -e

# Create stacker user
groupadd stacker
useradd -g stacker -s /bin/bash -d /home/stacker -m stacker
( umask 226 && echo "stacker ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/50_dev )
{
echo "PS1='${debian_chroot:+($debian_chroot)}\u:\w\$ '"
echo "source /home/stacker/refstack-client/.venv/bin/activate"
echo "alias 'refstack-client'=/home/stacker/refstack-client/refstack-client"
} >> /home/stacker/.bashrc

[ -d '/home/debian' ] && cp -r /home/debian/.ssh /home/stacker
[ -d '/home/ubuntu' ] && cp -r /home/ubuntu/.ssh /home/stacker
chown -R stacker:stacker /home/stacker/.ssh
apt-get update

#Clone refstack-client repo
su -c "git clone %REPO% /home/stacker/refstack-client" stacker
cd /home/stacker/refstack-client

#Setup environment
su -c "./setup_env" stacker
