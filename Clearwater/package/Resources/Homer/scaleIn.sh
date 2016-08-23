#!/usr/bin/env bash
monit unmonitor -g homer
sudo service homer stop
sudo monit unmonitor clearwater_cluster_manager
sudo monit unmonitor clearwater_config_manager
sudo monit unmonitor -g etcd
sudo service clearwater-etcd decommission