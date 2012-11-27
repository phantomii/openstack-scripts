#!/bin/bash

. $(dirname $(readlink -f $0))/00-lib.sh

init_keystone_auth

echo -n "Adding tenants ... "
ADMIN_TENANT=$(get_id keystone tenant-create --name=admin)
SERVICE_TENANT=$(get_id keystone tenant-create --name=$SERVICE_TENANT_NAME)
echo "done"

echo -n "Adding Admin tenant/user/role ... "
ADMIN_USER=$(get_id keystone user-create \
	--name=admin \
	--pass="$ADMIN_PASSWORD" \
	--email=admin@example.com)
ADMIN_ROLE=$(get_id keystone role-create --name=admin)
KEYSTONE_ADMIN_ROLE=$(get_id keystone role-create --name=KeystoneAdmin)
KEYSTONE_SERVICE_ROLE=$(get_id keystone role-create --name=KeystoneServiceAdmin)

for role in $ADMIN_ROLE $KEYSTONE_ADMIN_ROLE $KEYSTONE_SERVICE_ROLE; do
	keystone user-role-add \
	--user_id=$ADMIN_USER \
	--role_id=$role \
	--tenant_id=$ADMIN_TENANT;
done
echo "done"

# Keystone initialization
echo -n "Adding Keystone service ... "
KEYSTONE_SERVICE=$(get_id keystone service-create \
	--name=keystone \
	--type=identity \
	--description='OpenStack_Identity')
keystone endpoint-create \
	--region=$ENDPOINT_REGION \
	--service-id=$KEYSTONE_SERVICE \
	--publicurl=http://$KEYSTONE_PUB_HOST:5000/v2.0 \
	--adminurl=http://$KEYSTONE_ADMIN_HOST:35357/v2.0 \
	--internalurl=http://$KEYSTONE_HOST:5000/v2.0 >/dev/null
echo "done"
