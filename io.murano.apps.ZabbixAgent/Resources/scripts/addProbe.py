#!/usr/bin/env python
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
