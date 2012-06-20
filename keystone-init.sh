#!/bin/bash
#
# Variables set before calling this script:
# SERVICE_TOKEN - aka admin_token in keystone.conf
# SERVICE_ENDPOINT - local Keystone admin endpoint
# ADMIN_PASSWORD (optional) - the password that will be assigned to the "admin" user. By default is "nova"
# SERVICE_PASSWORD (optional) - the password that will be assigned to the "nova", "glance", "swift" users.
# 	The ADMIN_PASSWORD value will be used if not set.
# IP (optional) - the IP address of the cloud controller holding endpoints to the public services.
#	An easy way to set up endpoints.
# KEYSTONE_IP, NOVA_IP, GLANCE_IP, EC2_IP, SWIFT_IP, VOLUME_IP (optional) - the endpoint IP address of the corresponding service. 
# 	The IP value will be used if not set.


if [ -z "$SERVICE_TOKEN"  -o -z "$SERVICE_ENDPOINT" ]; then
  echo "Missing one of the mandatory arguments: SERVICE_TOKEN, SERVICE_ENDPOINT"
  exit 1
fi

export SERVICE_TOKEN=$SERVICE_TOKEN
export SERVICE_ENDPOINT=$SERVICE_ENDPOINT

ADMIN_PASSWORD=${ADMIN_PASSWORD:-nova}
SERVICE_PASSWORD=${SERVICE_PASSWORD:-$ADMIN_PASSWORD}
SERVICE_TENANT_NAME=${SERVICE_TENANT_NAME:-service}
ENDPOINT_REGION=RegionOne

KEYSTONE_IP=${KEYSTONE_IP:-$IP}
NOVA_IP=${NOVA_IP:-$IP}
EC2_IP=${EC2_IP:-$IP}
GLANCE_IP=${GLANCE_IP:-$IP}
SWIFT_IP=${SWIFT_IP:-$IP}
VOLUME_IP=${VOLUME_IP:-$IP}

if [ -z "$KEYSTONE_IP" -o -z "$NOVA_IP" -o -z "$EC2_IP" -o -z "$GLANCE_IP" -o -z "$SWIFT_IP" -o -z "$VOLUME_IP" ]; then
  echo "Either define IP or each of KEYSTONE_IP, NOVA_IP, EC2_IP, GLANCE_IP, SWIFT_IP, VOLUME_IP"
  exit 1
fi

function get_id () {
    echo `$@ | awk '/ id / { print $4 }'`
}

echo -n "Adding Service tenant ... "
SERVICE_TENANT=$(get_id keystone tenant-create --name=$SERVICE_TENANT_NAME)
echo "done"


#
echo -n "Adding Admin tenant/user/role ... "
ADMIN_USER=$(get_id keystone user-create --name=admin \
                                         --pass="$ADMIN_PASSWORD" \
                                         --email=admin@example.com)

ADMIN_ROLE=$(get_id keystone role-create --name=admin)
ADMIN_TENANT=$(get_id keystone tenant-create --name=admin)

keystone user-role-add --user $ADMIN_USER --role $ADMIN_ROLE --tenant_id $ADMIN_TENANT
echo "done"


# Member role isused within the Horizon as the default security level
echo -n "Adding Member role ..."
MEMBER_ROLE=$(get_id keystone role-create --name=Member)
echo "done"

# Keystone initialization
echo -n "Adding Keystone service ... "

KEYSTONEADMIN_ROLE=$(get_id keystone role-create --name=KeystoneAdmin)
KEYSTONESERVICE_ROLE=$(get_id keystone role-create --name=KeystoneServiceAdmin)

KEYSTONE_SERVICE=$(get_id keystone service-create --name=keystone \
                               --type=identity)
keystone endpoint-create \
 --region $ENDPOINT_REGION \
 --service_id=$KEYSTONE_SERVICE \
 --publicurl=http://$KEYSTONE_IP:5000/v2.0 \
 --internalurl=http://$KEYSTONE_IP:5000/v2.0 \
 --adminurl=http://$KEYSTONE_IP:35357/v2.0 >/dev/null

echo "done"


# Nova initialization
echo -n "Adding Nova service ... "

NOVA_USER=$(get_id keystone user-create --name=nova \
                                        --pass="$SERVICE_PASSWORD" \
                                        --tenant_id $SERVICE_TENANT \
                                        --email=nova@example.com)
keystone user-role-add --tenant_id $SERVICE_TENANT \
                       --user $NOVA_USER \
                       --role $ADMIN_ROLE

NOVA_SERVICE=$(get_id keystone service-create --name=nova \
                               --type=compute)
keystone endpoint-create \
 --region $ENDPOINT_REGION \
 --service_id=$NOVA_SERVICE \
 --publicurl="http://$NOVA_IP:8774/v2/%(tenant_id)s" \
 --internalurl="http://$NOVA_IP:8774/v2/%(tenant_id)s" \
 --adminurl="http://$NOVA_IP:8774/v2/%(tenant_id)s" >/dev/null

echo "done"

echo -n "Adding EC2 service ... "
EC2_SERVICE=$(get_id keystone service-create --name=ec2 --type=ec2)
keystone endpoint-create \
 --region $ENDPOINT_REGION \
 --service_id=$EC2_SERVICE \
 --publicurl=http://$EC2_IP:8773/services/Cloud \
 --internalurl=http://$EC2_IP:8773/services/Cloud \
 --adminurl=http://$EC2_IP:8773/services/Admin >/dev/null

echo "done"


echo -n "Adding Volume service ... "
VOLUME_SERVICE=$(get_id keystone service-create --name=volume --type=volume)

keystone endpoint-create \
 --region RegionOne \
 --service_id=$VOLUME_SERVICE \
 --publicurl="http://$VOLUME_IP:8776/v1/%(tenant_id)s" \
 --internalurl="http://$VOLUME_IP:8776/v1/%(tenant_id)s" \
 --adminurl="http://$VOLUME_IP:8776/v1/%(tenant_id)s" >/dev/null

echo "done"

# Glance initialization
echo -n "Adding Glance service ... "

GLANCE_USER=$(get_id keystone user-create --name=glance \
                                          --pass="$SERVICE_PASSWORD" \
                                          --tenant_id $SERVICE_TENANT \
                                          --email=glance@example.com)
keystone user-role-add --tenant_id $SERVICE_TENANT \
                       --user $GLANCE_USER \
                       --role $ADMIN_ROLE
GLANCE_SERVICE=$(get_id keystone service-create --name=glance --type=image)
keystone endpoint-create \
 --region $ENDPOINT_REGION \
 --service_id=$GLANCE_SERVICE \
 --publicurl=http://$GLANCE_IP:9292/v1 \
 --internalurl=http://$GLANCE_IP:9292/v1 \
 --adminurl=http://$GLANCE_IP:9292/v1 >/dev/null

echo "done"


# Swift initialization
echo -n "Adding Swift service ... "

SWIFT_USER=$(get_id keystone user-create --name=swift \
                                         --pass="$SERVICE_PASSWORD" \
                                         --tenant_id $SERVICE_TENANT \
                                         --email=swift@example.com)
keystone user-role-add --tenant_id $SERVICE_TENANT \
                       --user $SWIFT_USER \
                       --role $ADMIN_ROLE
# Nova needs ResellerAdmin role to download images when accessing
# swift through the s3 api. The admin role in swift allows a user
# to act as an admin for their tenant, but ResellerAdmin is needed
# for a user to act as any tenant. The name of this role is also
# configurable in swift-proxy.conf
RESELLER_ROLE=$(get_id keystone role-create --name=ResellerAdmin)
keystone user-role-add --tenant_id $SERVICE_TENANT \
                       --user $NOVA_USER \
                       --role $RESELLER_ROLE

SWIFT_SERVICE=$(get_id keystone service-create --name=swift --type=object-store)

keystone endpoint-create \
 --region $ENDPOINT_REGION \
 --service_id=$SWIFT_SERVICE \
 --publicurl "http://$SWIFT_IP:8080/v1/AUTH_\$(tenant_id)s" \
 --adminurl "http://$SWIFT_IP:8080/" \
 --internalurl "http://$SWIFT_IP:8080/v1/AUTH_\$(tenant_id)s" >/dev/null

echo "done"
