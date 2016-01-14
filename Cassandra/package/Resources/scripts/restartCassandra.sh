#!/bin/bash

## Restart service for any changes to take the effect
# Sleep for some time added as a helper
TIME="$1"

sleep $TIME
sudo service cassandra restart
