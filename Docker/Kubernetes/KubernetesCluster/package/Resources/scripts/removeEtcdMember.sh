#!/bin/bash

NODE_ID=$(/opt/bin/etcdctl member list | grep $1 | cut -d':' -f1)
/opt/bin/etcdctl member remove $NODE_ID
