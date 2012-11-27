#!/bin/bash

. $(dirname $(readlink -f $0))/00-lib.sh

init_keystone_auth

echo -n "Adding Member role ..."
keystone role-create --name=Member
echo "done"
