#!/bin/bash

. $(dirname $(readlink -f $0))/00-lib.sh

check_root

pvcreate $NOVA_LVM_BLOCK_DEVICE
vgcreate $NOVA_VOL_GROUP_NAME $NOVA_LVM_BLOCK_DEVICE

service nova-volume restart
