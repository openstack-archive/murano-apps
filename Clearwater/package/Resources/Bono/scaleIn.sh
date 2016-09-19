#!/usr/bin/env bash

monit unmonitor -g bono
sudo service bono quiesce
sudo monit unmonitor clearwater_cluster_manager
sudo monit unmonitor clearwater_config_manager
sudo monit unmonitor -g etcd
sudo service clearwater-etcd decommission