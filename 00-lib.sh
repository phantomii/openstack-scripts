BASE_DIR=$(dirname $(readlink -f $0))
CONFIG=$BASE_DIR/stackrc
LOCAL_CONFIG=localrc

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

function get_iface_ip()
{
	ifconfig $1 | grep 'inet addr' | cut -d":" -f2 | cut -d" " -f1
}


function get_my_ip()
{
	get_iface_ip $MANAGEMENT_IFACE
}

MY_IP=$(get_my_ip)
