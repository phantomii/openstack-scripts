#!/bin/bash

. $(dirname $(readlink -f $0))/00-lib.sh

check_root

apt-get install -y nova-compute nova-network nova-api-metadata

NOVA_COMPUTE_CONF=/etc/nova/nova-compute.conf

backup_file $NOVA_COMPUTE_CONF

cat >>$NOVA_COMPUTE_CONF <<EOF

# nova-compute configuration, appended by installation script
[DEFAULT]
libvirt_type=qemu
EOF

cat >>$NOVA_CONF <<NOVA_CONF

# nova-compute configuration, appended by installation script
novnc_enabled=True
novncproxy_base_url=http://$VNC_PUB_HOST:6080/vnc_auto.html
novncproxy_port=6080
xvpvncproxy_base_url=http://$VNC_PUB_HOST:6081/console
vncserver_listen=$MY_IP
vncserver_proxyclient_address=$MY_IP

# nova-network configuration, appended by installation script
multi_host=True
public_interface=$PUB_IFACE_NAME
network_manager=nova.network.manager.VlanManager
vlan_interface=$DATA_IFACE_NAME
vlan_start=$FIRST_VLAN
fixed_range=$FIXED_IP_RANGE
network_size=$NETWORK_SIZE
routing_source_ip=$(get_iface_ip $PUB_IFACE_NAME)
my_ip=$MY_IP
NOVA_CONF
