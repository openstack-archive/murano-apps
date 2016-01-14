#!/bin/bash

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

