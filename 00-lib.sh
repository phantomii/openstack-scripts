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
