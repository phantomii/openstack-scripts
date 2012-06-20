#!/bin/bash

. $(dirname $(readlink -f $0))/00-lib.sh

check_root

apt-get install -y keystone python-keystoneclient

KEYSTONE_CONFIG=/etc/keystone/keystone.conf

backup_file $KEYSTONE_CONFIG

cat >>$KEYSTONE_CONFIG <<KEYSTONE_CONFIG
[sql]
connection=mysql://keystone:$MYSQL_PASSWORD@$MYSQL_HOST/keystone
[DEFAULT]
admin_token=$KEYSTONE_ADMIN_TOKEN
[identity]
driver=keystone.identity.backends.sql.Identity
[catalog]
driver=keystone.catalog.backends.sql.Catalog
[token]
driver=keystone.token.backends.sql.Token
[ec2]
driver=keystone.contrib.ec2.backends.sql.Ec2
KEYSTONE_CONFIG

keystone-manage db_sync

service keystone restart
