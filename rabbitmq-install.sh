#!/bin/bash

. $(dirname $(readlink -f $0))/00-lib.sh

check_root

RABBITMQ_PKG=rabbitmq-server

# Install and start mysql-server
apt-get -y install $RABBITMQ_PKG

echo "RABBITMQ_NODE_IP_ADDRESS=$RABBITMQ_IP" > /etc/rabbitmq/rabbitmq.conf.d/bind-address

service rabbitmq-server restart
