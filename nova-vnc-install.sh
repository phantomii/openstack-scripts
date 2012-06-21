#!/bin/bash

. $(dirname $(readlink -f $0))/00-lib.sh

check_root

apt-get install -y  novnc nova-vncproxy

service nova-vncproxy restart
service novnc restart
