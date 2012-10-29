#!/bin/bash

. $(dirname $(readlink -f $0))/00-lib.sh

check_root

apt-get install -y keystone python-keystone python-keystoneclient

KEYSTONE_CONFIG=/etc/keystone/keystone.conf

backup_file $KEYSTONE_CONFIG

sed -i "s/# admin_token = ADMIN/admin_token = $ADMIN_TOKEN/g" $KEYSTONE_CONFIG
sed -i "s%connection = sqlite:////var/lib/keystone/keystone.db%connection = mysql://keystone:$KEYSTONE_DB_PASSWORD@$MYSQL_HOST/keystone%g" $KEYSTONE_CONFIG

keystone-manage db_sync

service keystone restart
