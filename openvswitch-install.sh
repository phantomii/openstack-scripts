#!/bin/bash

. $(dirname $(readlink -f $0))/00-lib.sh

check_root

apt-get install openvswitch-switch openvswitch-datapath-dkms

ovs-vsctl add-br br-int
ovs-vsctl add-br br-ex
ovs-vsctl add-port br-ex $DATA_IFACE_NAME
ovs-vsctl add-br br-eth1
ovs-vsctl add-port br-eth1 $PUB_IFACE_NAME
