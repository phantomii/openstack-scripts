#!/bin/bash

. $(dirname $(readlink -f $0))/00-lib.sh

check_root

apt-get install -y nova-api nova-cert nova-consoleauth nova-scheduler nova-network

service nova-network stop

