#!/bin/bash

. $(dirname $(readlink -f $0))/00-lib.sh

init_keystone_auth

# Glance initialization
echo -n "Adding Glance service ... "
GLANCE_USER=$(get_id keystone user-create \
	--name=glance \
	--pass=$SERVICE_PASSWORD \
	--tenant_id=$SERVICE_TENANT \
	--email=glance@example.com)
keystone user-role-add \
	--tenant_id=$SERVICE_TENANT \
	--user_id=$GLANCE_USER \
	--role_id=$ADMIN_ROLE
GLANCE_SERVICE=$(get_id keystone service-create \
	--name=glance \
	--type=image \
	--description='OpenStack_Image_Service')
keystone endpoint-create \
	--region=$ENDPOINT_REGION \
	--service-id=$GLANCE_SERVICE \
	--publicurl=http://$GLANCE_PUB_HOST:9292/v2 \
	--adminurl=http://$GLANCE_ADMIN_HOST:9292/v2 \
	--internalurl=http://$GLANCE_HOST:9292/v2
echo "done"
