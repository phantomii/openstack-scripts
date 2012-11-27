#!/bin/bash

. $(dirname $(readlink -f $0))/00-lib.sh

check_root

apt-get install -y quantum-server python-cliff python-pyparsing quantum-plugin-openvswitch

QUANTUM_CONF=/etc/quantum/quantum.conf
QUANTUM_API_PASTE=/etc/quantum/api-paste.ini
QUANTUM_L3_CONF=/etc/quantum/l3_agent.ini
NOVA_CONF=/etc/nova/nova.conf

backup_file $QUANTUM_CONF

cat >> $QUANTUM_CONF << QUANTUM_CONF
[DATABASE]
sql_connection = mysql://quantum:$QUANTUM_DB_PASSWORD@$MYSQL_HOST/quantum

[OVS]
tenant_network_type=vlan
network_vlan_ranges = physnet1:1:4094
bridge_mappings = physnet1:br-eth1
QUANTUM_CONF

backup_file $QUANTUM_API_PASTE

sed /auth_host/s/127.0.0.1/$KEYSTONE_HOST/ $QUANTUM_API_PASTE  | \
sed s/%SERVICE_TENANT_NAME%/$SERVICE_TENANT_NAME/ | \
sed s/%SERVICE_USER%/quantum/ | \
sed s/%SERVICE_PASSWORD%/$QUANTUM_USER_PASSWORD/ > $QUANTUM_API_PASTE

service quantum-server restart

apt-get install -y quantum-plugin-openvswitch-agent quantum-dhcp-agent quantum-dhcp-agent quantum-l3-agent

backup_file $QUANTUM_L3_CONF

sed /auth_url/s/localhost/$KEYSTONE_HOST/ $QUANTUM_L3_CONF  | \
sed s/%SERVICE_TENANT_NAME%/$SERVICE_TENANT_NAME/ | \
sed s/%SERVICE_USER%/quantum/ | \
sed s/%SERVICE_PASSWORD%/$QUANTUM_USER_PASSWORD/ > $QUANTUM_L3_CONF

service quantum-plugin-openvswitch-agent restart
service quantum-dhcp-agent restart
service quantum-l3-agent restart

cat >> NOVA_CONF << NOVA_CONF
network_api_class=nova.network.quantumv2.api.API
quantum_url=http://$QUANTUM_HOST:9696
quantum_auth_strategy=keystone
quantum_admin_tenant_name=$SERVICE_TENANT_NAME
quantum_admin_username=quantum
quantum_admin_password=$QUANTUM_USER_PASSWORD
quantum_admin_auth_url=http://$QUANTUM_HOST:35357/v2.0
libvirt_vif_driver=nova.virt.libvirt.vif.LibvirtOpenVswitchDriver
libvirt_use_virtio_for_bridges=True
NOVA_CONF
