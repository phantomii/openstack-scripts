#!/bin/bash

. $(dirname $(readlink -f $0))/00-lib.sh

check_root

RABBITMQ_PKG=rabbitmq-server

# Seed configuration with mysql password so that apt-get install doesn't
# prompt us for a password upon install.
#cat <<MYSQL_PRESEED | sudo debconf-set-selections
#$MYSQL_PKG mysql-server/root_password password $MYSQL_PASSWORD
#$MYSQL_PKG mysql-server/root_password_again password $MYSQL_PASSWORD
#$MYSQL_PKG mysql-server/start_on_boot boolean true
#MYSQL_PRESEED

# Install and start mysql-server
apt-get -y install $RABBITMQ_PKG

echo "RABBITMQ_NODE_IP_ADDRESS=$RABBITMQ_IP" > /etc/rabbitmq/rabbitmq.conf.d/bind-address

service rabbitmq-server restart
