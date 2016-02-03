#!/usr/bin/python
import json
import ConfigParser
import requests
import sys
import logging

logging.basicConfig(filename='/tmp/port-disable.log',level=logging.DEBUG)
data_file = "/etc/os_openvpn/os_openvpn.conf"

# parsing required input parameters from data file
config = ConfigParser.ConfigParser()
config.read(data_file)
config.sections()

instanceName = config.get('INSTANCE', 'instanceName')
envName = config.get('INSTANCE', 'envName')
OPENSTACK_IP = config.get('INSTANCE', 'OPENSTACK_IP')
tenant = config.get('INSTANCE', 'tenant')
username = config.get('INSTANCE', 'username')
password = config.get('INSTANCE', 'password')

token_id = ""
instance_info = None

# Default port numbers of OpenStack services 
public_endPoint = "5000"
neutron_service = "9696"
nova_endPoint = "8774"

# Requesting for auth token using OpenStack REST api
def get_keystone_token():
    global token_id
    url = 'https://'+OPENSTACK_IP+':'+public_endPoint+'/v2.0/tokens' 
    data = '{ "auth" : {"passwordCredentials": {"username": "'+username+'", "password": "'+password+'"}, "tenantName":"'+tenant+'"}}'
    try:
        request = requests.post(url, data=data, verify=False)
    except Exception as e:
        logging.debug('Error while gettting auth token')
        logging.debug('%s',request.status_code)
        sys.exit(1)
    decode_response = (request.text.decode('utf-8'))
    string = str(decode_response)
    token_info = json.loads(string)
    try:
        token_id = token_info["access"]["token"]["id"]
    except Exception as e:
        sys.exit(1)
    logging.info('Received auth token')

# Receiving and parsing instance details. Looking for instance id, port id, security group id, tenant id 
def instance_details():
    global instance_info
    url =  'https://'+OPENSTACK_IP+':'+neutron_service+'/v2.0/ports.json'
    headers = {"X-Auth-Token": token_id}
    try:
        request = requests.get(url, headers = headers, verify=False)
    except Exception as e:
        logging.debug('Error while gettting instance details')
        logging.debug('%s',request.status_code)
        sys.exit(1)
    decode_response = (request.text.decode('utf-8'))
    string = str(decode_response)
    ports_info = json.loads(string)
    for info in ports_info["ports"]:
        #if instanceIP in info['fixed_ips'][0]['ip_address']:
        if instanceName in info['name']:
            instance_info = info
    logging.info('Received instance details')

# Removing security group of an insatnce using REST api
def remove_secgroup():
    try:    
        instance_id = instance_info['device_id']
        security_id = instance_info['security_groups'][0]
        tenant_id = instance_info['tenant_id']
        port_id = instance_info['id']
    except Exception as e:
        sys.exit(1)
    #url = 'http://'+OPENSTACK_IP+':'+nova_endPoint+'/v2.1/'+tenant_id+'/servers/'+instance_id+'/action'
    url = 'https://'+OPENSTACK_IP+':'+neutron_service+'/v2.0/ports/'+port_id+'.json'
    headers = { "Content-Type": "application/json", "X-Auth-Token": token_id}
    #data = '{"removeSecurityGroup": {"name": "'+security_id+'"}}'
    data = '{"port": {"security_groups": []}}'
    try:
        request = requests.put(url, headers = headers, data = data, verify=False)
    except Exception as e:    
        logging.debug('Error while removing secgroup of an instance')
        logging.debug('%s',request.status_code)
        sys.exit(1)
    logging.info('Security group has removed of an instance')
    
# Disabling security port
def port_disable():
    try:
        port_id = instance_info['id']
    except Exception as e:
        sys.exit(1)
    url = 'https://'+OPENSTACK_IP+':'+neutron_service+'/v2.0/ports/'+port_id+'.json'
    headers = { "Content-Type": "application/json", "X-Auth-Token": token_id}
    data = '{"port": {"port_security_enabled": "False"}}'   
    try: 
        request = requests.put(url, headers = headers, data = data, verify=False)
    except Exception as e:
        logging.debug('Error while disabling securtiy port')
        logging.debug('%s',request.status_code)
        sys.exit(1)
    logging.info('Disabled scurtiy port')

get_keystone_token()
instance_details()
remove_secgroup()
port_disable()
