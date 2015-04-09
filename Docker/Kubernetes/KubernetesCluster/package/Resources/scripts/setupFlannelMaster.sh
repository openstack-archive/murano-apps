#!/bin/bash

/opt/bin/etcdctl mk /coreos.com/network/config '{"Network":"10.200.0.0/16"}'
