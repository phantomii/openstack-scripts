#!/bin/bash

. $(dirname $(readlink -f $0))/00-lib.sh

check_root

apt-get install -y cinder-api cinder-scheduler cinder-volume iscsitarget iscsitarget-dkms open-iscsi

CINDER_API_PASTE=/etc/cinder/api-paste.ini
CINDER_CONF=/etc/cinder/cinder.conf
NOVA_CONF=/etc/nova/nova.conf

backup_file $CINDER_API_PASTE

sed /service_host/s/127.0.0.1/$KEYSTONE_HOST/ $CINDER_API_PASTE  | \
sed /auth_host/s/127.0.0.1/$KEYSTONE_HOST/ | \
sed s/%SERVICE_TENANT_NAME%/$SERVICE_TENANT_NAME/ | \
sed s/%SERVICE_USER%/cinder/ | \
sed s/%SERVICE_PASSWORD%/$CINDER_USER_PASSWORD/ > $CINDER_API_PASTE

backup_file $CINDER_CONF

sed -i /iscsi_helper/s/tgtadm/ietadm/ $CINDER_CONF
echo "sql_connection = mysql://cinder:$CINDER_DB_PASSWORD@$MYSQL_HOST/cinder" >> $CINDER_CONF

backup_file $NOVA_CONF

cat >> $NOVA_CONF << NOVA_CONF
volume_api_class=nova.volume.cinder.API
osapi_volume_listen_port=5900
NOVA_CONF

cinder-manage db sync

service cinder-volume restart
service cinder-api restart
