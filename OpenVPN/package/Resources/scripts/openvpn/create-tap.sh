#!/bin/bash

set -e

# Parsing input parameters from conf
conf_file="/etc/os_openvpn/os_openvpn.conf"
publicServerPort=$(awk -F "=" '/^publicServerPort/ {print $2}' $conf_file)
publicServerIp=$(awk -F "=" '/^publicServerIp/ {print $2}' $conf_file)
gceNodesIp=$1
gceUserName="root"
# ssh key Generating
if [ ! -f ~/.ssh/id_rsa ]; then
   ssh-keygen -t rsa -f  ~/.ssh/id_rsa -N ''
fi


# Client IPs storing in a array
function create_client_array()
{
    while IFS=',' read -ra IP; do 
        for i in "${IP[@]}"; do
            CLIENTS_ARRAY+=("$i")
        done
    done <<< "$gceNodesIp"
}

# This func creates client names like new0, new1, new2...
# Change name pattern if required. ex: pattern="client-"
function create-client-name() {
    pattern="client-"
    count=0
    while true
    do
       name="$pattern$count"
       if [ ! -f /etc/openvpn/easy-rsa/keys/$name.crt ] && [ ! -f /etc/openvpn/easy-rsa/keys/$name.key ] 
       then
          CLIENT_NAME="$name"
          break
       else
          ((count=count+1))
          continue
       fi
    done
}

# Generating client certificates and copying 
function gen_cert()
{
    clientname=$1
    gceIp=$2
    cd /etc/openvpn/easy-rsa
    source ./vars
    ./pkitool ${clientname}
 
    if [ -f ~/ssh/known_hosts ] ; then
      ssh-keygen -f ~/ssh/known_hosts -R ${gceIp}
    fi
    ssh-keyscan ${gceIp} >> ~/.ssh/known_hosts

    ssh ${gceUserName}@${gceIp} uptime
    ssh ${gceUserName}@${gceIp} sudo apt-get update
    ssh ${gceUserName}@${gceIp} sudo apt-get install -y openvpn

    scp /opt/openvpn/templates/client.conf /etc/openvpn/easy-rsa/keys/ca.crt /etc/openvpn/easy-rsa/keys/ta.key /etc/openvpn/easy-rsa/keys/${clientname}.crt /etc/openvpn/easy-rsa/keys/${clientname}.key ${gceUserName}@${gceIp}:

    ssh ${gceUserName}@${gceIp} sed -ie s/SERVER_PORT/${publicServerPort}/ client.conf
    ssh ${gceUserName}@${gceIp} sed -ie s/SERVER_IP/${publicServerIp}/ client.conf
    ssh ${gceUserName}@${gceIp} sed -ie s/CLIENT/${clientname}/ client.conf
    ssh ${gceUserName}@${gceIp} sudo cp client.conf ca.crt ta.key ${clientname}.crt ${clientname}.key /etc/openvpn

    ssh ${gceUserName}@${gceIp} sudo service openvpn restart
}


create_client_array
for ip in "${CLIENTS_ARRAY[@]}"
do
  
   create-client-name
   gen_cert $CLIENT_NAME $ip

done
