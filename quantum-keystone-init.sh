#!/bin/bash

. $(dirname $(readlink -f $0))/00-lib.sh

init_keystone_auth

echo -n "Adding Volume service ... "
QUANTUM_USER=$(get_id keystone user-create \
	--name=quantum \
	--pass=$SERVICE_PASSWORD \
	--tenant_id=$SERVICE_TENANT \
	--email=quantum@example.com)
keystone user-role-add \
	--tenant_id=$SERVICE_TENANT \
	--user_id=$QUANTUM_USER \
	--role_id=$ADMIN_ROLE
CINDER_SERVICE=$(get_id keystone service-create \
	--name=quantum \
	--type=network \
	--description='OpenStack_Network_Service')
keystone endpoint-create \
	--region=$ENDPOINT_REGION \
	--service-id=$QUANTUM_SERVICE \
	--publicurl="http://$QUANTUM_PUB_HOST:9696/" \
	--adminurl="http://$QUANTUM_ADMIN_HOST:9696/" \
	--internalurl="http://$QUANTUM_HOST:9696/" > /dev/null
echo "done"
