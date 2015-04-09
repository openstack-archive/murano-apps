import json
import requests


class ZabbixApi():
    def __init__(self, hostname, server_ip, username, password):
        self.session = requests.Session()
        # Default headers for all requests
        self.session.headers.update({
            'Content-Type': 'application/json-rpc',
            'User-Agent': 'python/pyzabbix'
        })

        self.req_id = 0
        self.auth_token = 0
        self.url = 'http://%s/zabbix/api_jsonrpc.php' % server_ip
        self.username = username
        self.password = password
        self.hostname = hostname

        self.authenticate()

    def authenticate(self):
        params = {
            'user': self.username,
            'password': self.password
        }
        self.auth_token = self.doRequest('user.login', params=params)['result']

    # noinspection PyPep8Naming
    def doRequest(self, method, params=None):
        request_json = {
            'jsonrpc': '2.0',
            'method': method,
            'params': params or {},
            'id': self.req_id,
        }

        if self.auth_token:
            request_json['auth'] = self.auth_token

        response = self.session.post(
            self.url,
            data=json.dumps(request_json),
            timeout=30
        )
        response.raise_for_status()

        if not len(response.text):
            raise Exception("Received empty response")

        try:
            response_json = json.loads(response.text)
        except ValueError:
            raise Exception(
                "Unable to parse json: %s" % response.text
            )

        self.req_id += 1

        return response_json

    # noinspection PyPep8Naming
    def createGroup(self, name):
        response = self.doRequest('hostgroup.create', params={'name': name})
        return response['result']['groupids'][0]

    # noinspection PyPep8Naming
    def createHost(self, groupId, instanceIp, name):
        params = {
            "host": name,
            "interfaces": [{
                "type": 1,
                "main": 1,
                "useip": 1,
                "ip": instanceIp,
                "dns": "",
                "port": "10050"
            }],
            "groups": [{
                "groupid": groupId,
            }]
        }
        response = self.doRequest('host.create', params=params)
        return response['result']['hostids'][0]

    # noinspection PyPep8Naming
    def createItem(self, hostId, interface, key):
        params = {
            "name": "check host",
            "key_": key,
            "hostid": hostId,
            "type": 0,
            "interfaceid": interface,
            "value_type": 3,
            "delay": 5
        }
        response = self.doRequest('item.create', params=params)
        return response

    # noinspection PyPep8Naming
    def getInterfacesForHost(self, hostId):
        params = {
            "output": "extend",
            "hostids": hostId
        }
        response = self.doRequest('hostinterface.get', params=params)
        interfaces = []

        for res in response['result']:
            interfaces.append(res['interfaceid'])

        return interfaces

    # noinspection PyPep8Naming
    def getTemplateIdByName(self, tName):
        params = {
            "output": "extend",
            "filter": {
                "host": tName
            }
        }

        response = self.doRequest('template.get', params=params)
        return response['result'][0]['templateid']

    # noinspection PyPep8Naming
    def addProbe(self, probeType, instanceIp):
        http_template = 'Template App HTTP Service'
        icmp_template = 'Template ICMP Ping'

        groupId = self.createGroup('%s-group' % self.hostname)
        hostId = self.createHost(groupId, instanceIp, self.hostname)
        interfaces = self.getInterfacesForHost(hostId)

        tName = http_template if probeType == 'HTTP' else icmp_template
        templateId = self.getTemplateIdByName(tName)

        params = {
            "hosts": [{
                "hostid": hostId
            }],
            "templates": [{
                "templateid": templateId
            }]
        }

        response = self.doRequest('host.massadd', params=params)
