#!/bin/bash

. $(dirname $(readlink -f $0))/00-lib.sh

check_root

NOVA_CONFIG=/etc/nova/nova.conf
NOVA_API_PASTE=/etc/nova/api-paste.ini

apt-get install -y nova-api nova-cert nova-consoleauth nova-scheduler nova-network

service nova-network stop

nova-manage db sync
nova-manage network create private --fixed_range_v4=$FIXED_RANGE --num_networks=1 --bridge=br$FIRST_VLAN --bridge_interface=$VLAN_IFACE
nova-manage floating create --ip_range=$FLOATING_RANGE --interface=$PUBLIC_IFACE

cat >>$NOVA_CONFIG <<NOVA_CONFIG
--connection_type=libvirt
--public_interface=$PUBLIC_IFACE
--multi_host
NOVA_CONFIG

cat >>$NOVA_API_PASTE <<NOVA_API_PASTE
[filter:authtoken]
service_host = $KEYSTONE_HOST
service_port = 5000

auth_host = $KEYSTONE_HOST
auth_port = 35357
auth_protocol = http
auth_uri = http://$KEYSTONE_HOST:5000/

admin_tenant_name = $SERVICE_TENANT_NAME
admin_user = nova
admin_password = $SERVICE_PASSWORD
NOVA_API_PASTE
