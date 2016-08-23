#!/usr/bin/env bash
monit unmonitor -g homestead
monit unmonitor -g homestead-prov
sudo service homestead stop && sudo service homestead-prov stop
sudo monit unmonitor clearwater_cluster_manager
sudo monit unmonitor clearwater_config_manager
sudo monit unmonitor -g etcd
sudo service clearwater-etcd decommission