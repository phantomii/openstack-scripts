#!/bin/bash

. $(dirname $(readlink -f $0))/00-lib.sh

init_keystone_auth

echo -n "Adding EC2 service ... "
EC2_SERVICE=$(get_id keystone service-create \
	--name=ec2 \
	--type=ec2 \
	--description='OpenStack_EC2_service')
keystone endpoint-create \
	--region=$ENDPOINT_REGION \
	--service-id=$EC2_SERVICE \
	--publicurl=http://$EC2_PUB_HOST:8773/services/Cloud \
	--adminurl http://$EC2_ADMIN_HOST:8773/services/Admin \
	--internalurl http://$EC2_HOST:8773/services/Cloud
echo "done"
