#!/bin/bash

## Add public keys and signatures
gpg --keyserver pgp.mit.edu --recv-keys F758CE318D77295D
gpg --export --armor F758CE318D77295D | sudo apt-key add -

# Starting from Debian 0.7.5, more keys
gpg --keyserver pgp.mit.edu --recv-keys 2B5C1B00
gpg --export --armor 2B5C1B00 | sudo apt-key add -

gpg --keyserver pgp.mit.edu --recv-keys 0353B12C
gpg --export --armor 0353B12C | sudo apt-key add -

## Add Apache Software Foundation repositories
sudo sh -c 'echo "deb http://www.apache.org/dist/cassandra/debian 21x main" > /etc/apt/sources.list.d/apache-cassandra.sources.list'
sudo sh -c 'echo "deb-src http://www.apache.org/dist/cassandra/debian 21x main" >> /etc/apt/sources.list.d/apache-cassandra.sources.list'

sudo apt-get update

## Install from package
sudo apt-get -y install cassandra cassandra-tools

## Stop Cassandra and delete initial tables (to change name from Test Cluster)
sudo service cassandra stop
sudo rm -rf /var/lib/cassandra/data/*
sudo rm -rf /var/lib/cassandra/commitlog/*
sudo rm -rf /var/lib/cassandra/saved_caches/*

