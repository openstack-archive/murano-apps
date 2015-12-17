#!/usr/bin/python
import json
import ConfigParser
import requests
import sys

data_file = "/etc/os_openvpn/os_openvpn.conf"

config = ConfigParser.ConfigParser()
config.read(data_file)
config.sections()

# parsing required parameters from data file
instanceName = config.get('INSTANCE', 'instanceName')
envName = config.get('INSTANCE', 'envName')
OPENSTACK_IP = config.get('INSTANCE', 'OPENSTACK_IP')
tenant = config.get('INSTANCE', 'tenant')
username = config.get('INSTANCE', 'username')
password = config.get('INSTANCE', 'password')

token_id = ""
instance_info = None

# Requesting for auth token

def get_keystone_token():
    global token_id
    url = 'http://'+OPENSTACK_IP+':5000/v2.0/tokens'
    data = '{ "auth" : {"passwordCredentials": {"username": "'+username+'", "password": "'+password+'"}, "tenantName":"'+tenant+'"}}'
    #print data
    request = requests.post(url, data=data)
    if request.status_code != 200:
        print "Error while gettting auth token"
        print request.status_code
        sys.exit()
    decode_response = (request.text.decode('utf-8'))
    string = str(decode_response)
    token_info = json.loads(string)
    token_id = token_info["access"]["token"]["id"]
    print "Received auth token"

# Receiving and parsing instance details and Looking for instance id, port id, security group id, tenant id 

def instance_details():
    global instance_info
    url =  'http://'+OPENSTACK_IP+':9696/v2.0/ports.json'
    headers = {"X-Auth-Token": token_id}
    request = requests.get(url, headers = headers)
    if request.status_code != 200:
        print "Error while requesting to instance details"
        print request.status_code
        sys.exit()
    decode_response = (request.text.decode('utf-8'))
    string = str(decode_response)
    ports_info = json.loads(string)
    for info in ports_info["ports"]:
        if instanceName in info['name']:
            instance_info = info
    print "Received instance details" 

# Removing security group of an insatnce
def remove_secgroup():
    
    instance_id = instance_info['device_id']
    security_id = instance_info['security_groups'][0]
    tenant_id = instance_info['tenant_id']
    # print instance_id, security_id, tenant_id            

    url = 'http://'+OPENSTACK_IP+':8774/v2.1/'+tenant_id+'/servers/'+instance_id+'/action'
    headers = { "Content-Type": "application/json", "X-Auth-Token": token_id}
    data = '{"removeSecurityGroup": {"name": "'+security_id+'"}}'
    request = requests.post(url, headers = headers, data = data)
    if request.status_code != 202:
        print "Error while removing secgroup of an instance"
        print request.status_code
        sys.exit()
    print "Security group removed of an instance"
    
# Disabling security port
def port_disable():
    port_id = instance_info['id']
    url = 'http://'+OPENSTACK_IP+':9696/v2.0/ports/'+port_id+'.json'
    headers = { "Content-Type": "application/json", "X-Auth-Token": token_id}
    data = '{"port": {"port_security_enabled": "False"}}'    
    request = requests.put(url, headers = headers, data = data)
    if request.status_code != 200:
        print "Error while disabling securtiy port"
        print request.status_code
        sys.exit()
    print "Disabled scurtiy port"

get_keystone_token()
instance_details()
remove_secgroup()
port_disable()
