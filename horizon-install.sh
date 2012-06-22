#!/bin/bash

. $(dirname $(readlink -f $0))/00-lib.sh

check_root

apt-get install -y openstack-dashboard
cat >>/etc/openstack-dashboard/local_settings.py <<CONF
# NOTE: the configuration below was appended by installation script
OPENSTACK_HOST = "$KEYSTONE_HOST"
CONF

service apache2 restart
