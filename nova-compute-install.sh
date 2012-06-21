#!/bin/bash

. $(dirname $(readlink -f $0))/00-lib.sh

check_root

apt-get install -y nova-volume

cat >>$NOVA_CONF <<NOVA_CONF
--iscsi_ip_address=$MY_IP
--volume_group=$VOLUME_GROUP_NAME
NOVA_CONF
