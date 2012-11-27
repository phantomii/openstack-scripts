#!/bin/bash

. $(dirname $(readlink -f $0))/00-lib.sh

init_keystone_auth

echo -n "Adding Volume service ... "
CINDER_USER=$(get_id keystone user-create \
	--name=cinder \
	--pass=$SERVICE_PASSWORD \
	--tenant_id=$SERVICE_TENANT \
	--email=cinder@example.com)
keystone user-role-add \
	--tenant_id=$SERVICE_TENANT \
	--user_id=$CINDER_USER \
	--role_id=$ADMIN_ROLE
CINDER_SERVICE=$(get_id keystone service-create \
	--name=cinder \
	--type=volume \
	--description='OpenStack_Volume_Service')
keystone endpoint-create \
	--region=$ENDPOINT_REGION \
	--service-id=$CINDER_SERVICE \
	--publicurl="http://$CINDER_PUB_HOST:8776/v1/$(tenant_id)s" \
	--adminurl="http://$CINDER_ADMIN_HOST:8776/v1/$(tenant_id)s" \
	--internalurl="http://$CINDER_HOST:8776/v1/$(tenant_id)s" > /dev/null
echo "done"
