#!/bin/bash
sudo apt-get update
sudo apt-get -y -q install tomcat7
sudo iptables -I INPUT 1 -p tcp -m tcp --dport 8080 -j ACCEPT -m comment --comment "by murano, Tomcat"
