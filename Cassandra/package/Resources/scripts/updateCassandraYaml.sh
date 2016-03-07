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

CLUSTER_NAME="$1"
SEED_NODES="$2"
LISTEN_ADDRESS="$3"

## Configure Cassandra to use seed nodes
# Set cluster name
sed -e "s/cluster_name:.*/cluster_name: \'$CLUSTER_NAME\'/g" -i /etc/cassandra/cassandra.yaml
# Seed provider class name
sed -e "s/- class_name:.*/- class_name: org.apache.cassandra.locator.SimpleSeedProvider/g" -i /etc/cassandra/cassandra.yaml
# Set seed nodes - nodes used to bootstrap other nodes
sed -e "s/seeds:.*/seeds: \"$SEED_NODES\"/g" -i /etc/cassandra/cassandra.yaml
# Set listen address and endpoint snitch class
sed -e "s/listen_address:.*/listen_address: $LISTEN_ADDRESS/g" -i /etc/cassandra/cassandra.yaml
sed -e "s/endpoint_snitch:.*/endpoint_snitch: GossipingPropertyFileSnitch/g" -i /etc/cassandra/cassandra.yaml
# Set RPC address
sed -e "s/^rpc_address:.*/rpc_address: 0.0.0.0/g" -i /etc/cassandra/cassandra.yaml
sed -e "s/#\s*broadcast_rpc_address:.*/broadcast_rpc_address: $LISTEN_ADDRESS/g" -i /etc/cassandra/cassandra.yaml

