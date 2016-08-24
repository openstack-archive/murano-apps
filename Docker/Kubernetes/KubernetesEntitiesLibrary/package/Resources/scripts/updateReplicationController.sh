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

if [ "$1" == "True" ]; then
  echo "Creating a new Replication Controller" >> /tmp/murano-kube.log
  /opt/bin/kubectl create -f /tmp/controller.json >> /tmp/murano-kube.log
else
  echo "Updating a Replication Controller" >> /tmp/murano-kube.log
  /opt/bin/kubectl replace -f /tmp/controller.json >> /tmp/murano-kube.log
fi
