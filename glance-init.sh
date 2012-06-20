#!/bin/bash

. $(dirname $(readlink -f $0))/00-lib.sh

IMAGE_URL=${IMAGE_URL:-"http://launchpad.net/cirros/trunk/0.3.0/+download/cirros-0.3.0-x86_64-uec.tar.gz"}

OS_USER=${OS_USER:-admin}
OS_TENANT=${OS_TENANT:-admin}
OS_PASSWORD=$ADMIN_PASSWORD

TEMP=$(mktemp -d)
IMG_DIR=$TEMP/image
IMG_FILE=$(basename $IMAGE_URL)
IMG_NAME="${IMG_FILE%-*}"

function glance_it() {
	glance -I $OS_USER -T $OS_TENANT -K $OS_PASSWORD -N http://$KEYSTONE_HOST:5000/v2.0 -H $GLANCE_HOST $@
}

function extract_id() {
	cut -d ":" -f2 | tr -d " "
}

function findfirst() {
	find $IMG_DIR -name "$1" | head -1
}

echo "Downloading image ... "
wget $IMAGE_URL --directory-prefix=$TEMP || exit $?

echo "Unpacking image ... "
mkdir $IMG_DIR
tar -xvzf $TEMP/$IMG_FILE -C $IMG_DIR || exit $?

echo -n "Adding kernel ... "
KERNEL_ID=$(glance_it add --silent-upload name="$IMG_NAME-kernel" is_public=true container_format=aki disk_format=aki < $(findfirst '*-vmlinuz')  | extract_id)
echo "done."

echo -n "Adding ramdisk ... "
RAMDISK_ID=$(glance_it add --silent-upload name="$IMG_NAME-ramdisk" is_public=true container_format=ari disk_format=ari < $(findfirst '*-initrd') | extract_id)
echo "done."

echo -n "Adding image ... "
glance_it add --silent-upload name="$IMG_NAME" is_public=true container_format=ami disk_format=ami kernel_id=$KERNEL_ID ramdisk_id=$RAMDISK_ID < $(findfirst '*.img') >/dev/null
echo "done."

glance_it index
