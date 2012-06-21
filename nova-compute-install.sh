#!/bin/bash

. $(dirname $(readlink -f $0))/00-lib.sh

check_root

apt-get install -y nova-volume

cat >/etc/nova/nova-compute.conf <<EOF
--libvirt_type=qemu
EOF

apt-get install nova-compute nova-network nova-api-metadata

cat >>$NOVA_CONF <<NOVA_CONF
# nova-compute configuration
--vnc_enabled
--novncproxy_base_url=http://$VNC_PUB_HOST:6080/vnc_auto.html
--xvpvncproxy_base_url=http://$VNC_PUB_HOST:6081/console
--vncserver_listen=0.0.0.0
--vncserver_proxyclient_address=0.0.0.0

# nova-network configuration
--multi_host
--public_interface=$PUBLIC_IFACE
--network_manager=nova.network.manager.VlanManager
--vlan_interface=$VLAN_IFACE
--vlan_start=$FIRST_VLAN
--fixed_range=$FIXED_RANGE
--network_size=$NETWORK_SIZE
--routing_source_ip=$(get_iface_ip $PUBLIC_IFACE)
--my_ip=$MY_IP
NOVA_CONF
