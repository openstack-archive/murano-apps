#!/bin/sh
BR=$1
DEV=$2
MTU=$3
/sbin/ip link set "$DEV" up promisc on mtu "$MTU"
/sbin/brctl addif $BR $DEV

