#!/bin/bash

mysql --user=root --password=root -e "CREATE USER '$1'@'localhost' IDENTIFIED BY '$2'"
mysql --user=root --password=root -e "CREATE USER '$1'@'%' IDENTIFIED BY '$2'"
