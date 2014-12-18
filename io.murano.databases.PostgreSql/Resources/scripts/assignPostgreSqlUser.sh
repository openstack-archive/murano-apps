#!/bin/bash

sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $1 to $2"
tee --append /etc/postgresql/*/main/pg_hba.conf <<< "host $1 $2 all md5"
sudo /etc/init.d/postgresql restart
