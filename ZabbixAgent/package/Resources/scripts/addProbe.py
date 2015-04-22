#!/usr/bin/env python
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

import os.path
import sys

sys.path.insert(0, os.getcwd())
from zabbixApi import ZabbixApi


if __name__ == "__main__":
    probeType = sys.argv[1]
    server_ip = sys.argv[2]
    hostname = sys.argv[3]
    host_ip = sys.argv[4]

    Api = ZabbixApi(hostname, server_ip, 'admin', 'zabbix')

    Api.addProbe(probeType, host_ip)
