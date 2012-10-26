#!/bin/bash

. $(dirname $(readlink -f $0))/00-lib.sh

check_root

apt-get install -y openstack-dashboard

sed -i "/^OPENSTACK_HOST/s/= \"127.0.0.1\"/ = \"$KEYSTONE_PUB_HOST\"/g" /etc/openstack-dashboard/local_settings.py

service apache2 restart
