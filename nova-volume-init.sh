#!/bin/bash

. $(dirname $(readlink -f $0))/00-lib.sh

check_root

pvcreate $LVM_BLOCK_DEVICE
vgcreate $VOLUME_GROUP_NAME $LVM_BLOCK_DEVICE

service nova-volume restart
