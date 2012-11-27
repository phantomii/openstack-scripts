#!/bin/bash

. $(dirname $(readlink -f $0))/00-lib.sh

init_keystone_auth

# Nova initialization
echo -n "Adding Nova service ... "
NOVA_USER=$(get_id keystone user-create \
	--name=nova \
	--pass="$SERVICE_PASSWORD" \
	--tenant_id=$SERVICE_TENANT \
	--email=nova@example.com)
keystone user-role-add \
	--tenant_id=$SERVICE_TENANT \
	--user_id=$NOVA_USER \
	--role_id=$ADMIN_ROLE
NOVA_SERVICE=$(get_id keystone service-create \
	--name=nova \
	--type=compute \
	--description='OpenStack_Compute_Service')
keystone endpoint-create \
	--region=$ENDPOINT_REGION \
	--service-id=$NOVA_SERVICE \
	--publicurl="http://$NOVA_PUB_HOST:8774/v2/%(tenant_id)s" \
	--internalurl="http://$NOVA_HOST:8774/v2/%(tenant_id)s" \
	--adminurl="http://$NOVA_ADMIN_HOST:8774/v2/%(tenant_id)s" >/dev/null
echo "done"

