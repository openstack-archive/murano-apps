#!/bin/bash

# $1 - service name
# $2 - publicIPs JSON

/opt/bin/kubectl update service "$1" --patch="$2"
