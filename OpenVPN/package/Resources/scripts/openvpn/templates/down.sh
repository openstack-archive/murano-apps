#!/bin/sh
BR=$1
DEV=$2
/sbin/brctl delif $BR $DEV
/sbin/ip link set "$DEV" down" up promisc on mtu "$MTU"

