#!/bin/bash

. $(dirname $(readlink -f $0))/00-lib.sh

check_root

apt-get install -y nova-common

NOVA_CONFIG=/etc/nova/nova.conf

backup_file $NOVA_CONFIG

cat >$NOVA_CONFIG <<NOVA_CONFIG

# nova-common configuration,  appended by installation script
[DEFAULT]
dhcpbridge_flagfile=/etc/nova/nova.conf
dhcpbridge=/usr/bin/nova-dhcpbridge
logdir=/var/log/nova
state_path=/var/lib/nova
lock_path=/var/lock/nova
force_dhcp_release=True
iscsi_helper=tgtadm
libvirt_use_virtio_for_bridges=True
connection_type=libvirt
root_helper=sudo nova-rootwrap
verbose=True
ec2_private_dns_show_ip=True
sql_connection=mysql://nova:$NOVA_DB_PASSWORD@$MYSQL_HOST/nova
rabbit_host=$RABBITMQ_IP
auth_strategy=keystone
glance_api_servers=$GLANCE_HOST:9292
glance_host=$GLANCE_HOST
NOVA_CONFIG
