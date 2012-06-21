BASE_DIR=$(dirname $(readlink -f $0))
CONFIG=$BASE_DIR/stackrc
LOCAL_CONFIG=localrc

NOVA_CONF=/etc/nova/nova.conf

function check_root()
{
	if test "$(whoami)" != "root" ; then
		echo "$0 must be run as root" >&2
		exit 1
	fi
}


function read_config()
{
	. $CONFIG
	if test -e $LOCAL_CONFIG; then
		echo "using local configuration file $LOCAL_CONFIG" >&2
		. $LOCAL_CONFIG
	fi
}

read_config

function merge_config()
{
	$BASE_DIR/merge-config.py $@
}


function backup_file()
{
	cp $1 $1.orig
}

function nova-common_install()
{
	check_root
	apt-get install -y nova-common 
	NOVA_CONFIG=/etc/nova/nova.conf
	backup_file $NOVA_CONFIG
	cat >>$NOVA_CONFIG <<NOVA_CONFIG
--dhcpbridge_flagfile=/etc/nova/nova.conf
--dhcpbridge=/usr/bin/nova-dhcpbridge
--logdir=/var/log/nova
--state_path=/var/lib/nova
--lock_path=/var/lock/nova
--force_dhcp_release
--iscsi_helper=tgtadm
--libvirt_use_virtio_for_bridges
--connection_type=libvirt
--root_helper=sudo nova-rootwrap
--verbose
--ec2_private_dns_show_ip
--sql_connection=mysql://nova:$MYSQL_PASSWORD@$MYSQL_HOST/nova
--rabbit_host=$RABBITMQ_IP
--auth_strategy=keystone
--glance_api_servers=$GLANCE_HOST:9292
--glance_host=$GLANCE_HOST
NOVA_CONFIG
	nova-manage db sync
	nova-manage network create private --fixed_range_v4=$FIXED_RANGE --num_networks=1 --bridge=br$FIRST_VLAN --bridge_interface=$VLAN_IFACE
	nova-manage floating create --ip_range=$FLOATING_RANGE --interface=$PUBLIC_IFACE
}

function get_iface_ip()
{
	ifconfig $1 | grep 'inet addr' | cut -d":" -f2 | cut -d" " -f1
}


function get_my_ip()
{
	get_iface_ip $MANAGEMENT_IFACE
}
