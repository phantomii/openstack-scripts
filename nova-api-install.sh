#!/bin/bash

. $(dirname $(readlink -f $0))/00-lib.sh

check_root

NOVA_CONFIG=/etc/nova/nova.conf

apt-get install -y nova-api nova-cert nova-consoleauth nova-scheduler nova-network

service nova-network stop

nova-manage db sync
nova-manage network create private --fixed_range_v4=$FIXED_RANGE --num_networks=1 --bridge=br$FIRST_VLAN --bridge_interface=$VLAN_IFACE
nova-manage floating create --ip_range=$FLOATING_RANGE --interface=$PUBLIC_IFACE

echo "--connection_type=libvirt" >> $NOVA_CONFIG
echo "--public_interface=$PUBLIC_INTERFACE" >> $NOVA_CONFIG
echo "--multi_host" >> $NOVA_CONFIG
