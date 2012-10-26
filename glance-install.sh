#!/bin/bash

. $(dirname $(readlink -f $0))/00-lib.sh

check_root

apt-get install -y glance glance-api glance-client glance-common glance-registry python-glance

GLANCE_API_INI=/etc/glance/glance-api-paste.ini
GLANCE_API_CONF=/etc/glance/glance-api.conf
GLANCE_REG_INI=/etc/glance/glance-registry-paste.ini
GLANCE_REG_CONF=/etc/glance/glance-registry.conf

backup_file $GLANCE_API_INI

cat >>$GLANCE_API_INI <<GLANCE_INI
# NOTE: the configuration below was appended by installation script
[filter:authtoken]
service_host = $KEYSTONE_HOST
service_port = 5000

auth_host = $KEYSTONE_HOST
auth_port = 35357
auth_protocol = http
auth_uri = http://$KEYSTONE_HOST:5000/

admin_tenant_name = $SERVICE_TENANT_NAME
admin_user = glance
admin_password = $SERVICE_PASSWORD
GLANCE_INI


backup_file $GLANCE_API_CONF

cat >>$GLANCE_API_CONF <<GLANCE_CONF
# NOTE: the configuration below was appended by installation script
flavor = keystone
GLANCE_CONF


backup_file $GLANCE_REG_INI

cat >>$GLANCE_REG_INI <<GLANCE_INI
# NOTE: the configuration below was appended by installation script
[filter:authtoken]
service_host = $KEYSTONE_HOST
service_port = 5000

auth_host = $KEYSTONE_HOST
auth_port = 35357
auth_protocol = http
auth_uri = http://$KEYSTONE_HOST:5000/

admin_tenant_name = $SERVICE_TENANT_NAME
admin_user = glance
admin_password = $SERVICE_PASSWORD
GLANCE_INI


backup_file $GLANCE_REG_CONF

GLANCE_DB_CONFIG_STR="# NOTE: the configuration below was appended by installation script\n\
sql_connection = mysql://glance:$MYSQL_PASSWORD@$MYSQL_HOST/glance\n\
# sql_connection"

sed -i "s%^sql_connection%$GLANCE_DB_CONFIG_STR%g" $GLANCE_REG_CONF

cat >>$GLANCE_REG_CONF <<GLANCE_CONF
# NOTE: the configuration below was appended by installation script
flavor = keystone
GLANCE_CONF

#glance-manage version_control 0
glance-manage db_sync

service glance-api restart
service glance-registry restart
