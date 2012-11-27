#!/bin/bash

. $(dirname $(readlink -f $0))/00-lib.sh

init_keystone_auth

echo -n "Adding Volume service ... "
VOLUME_SERVICE=$(get_id keystone service-create --name=volume --type=volume)
keystone endpoint-create \
	--region=$ENDPOINT_REGION \
	--service_id=$VOLUME_SERVICE \
	--publicurl="http://$VOLUME_PUB_HOST:8776/v1/%(tenant_id)s" \
	--internalurl="http://$VOLUME_HOST:8776/v1/%(tenant_id)s" \
	--adminurl="http://$VOLUME_HOST:8776/v1/%(tenant_id)s" >/dev/null
echo "done"
