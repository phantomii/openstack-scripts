#!/bin/bash

. $(dirname $(readlink -f $0))/00-lib.sh

check_root

MYSQL_PKG=mysql-server-5.5

# Disable interactive mode on installation
export DEBIAN_FRONTEND=noninteractive

# Install and start mysql-server
apt-get -y install $MYSQL_PKG
# Set password for root
sudo mysqladmin -u root password $MYSQL_PASSWORD
# Update the DB to give user ‘$MYSQL_USER’@’%’ full control of the all databases:
sudo mysql -uroot -p$MYSQL_PASSWORD -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' identified by '$MYSQL_PASSWORD';"

# Update ``my.cnf`` for some local needs and restart the mysql service
MY_CONF=/etc/mysql/my.cnf

# Change ‘bind-address’ from localhost (127.0.0.1) to any (0.0.0.0)
sudo sed -i "/^bind-address/s/127.0.0.1/$MYSQL_HOST/g" $MY_CONF

echo "Restarting MySQL"

service mysql restart

echo "Creating users and databases"

for ROLE in nova keystone glance cinder quantum
do
DB=$ROLE
MYSQL_USER=$ROLE

DB_PASSWORD_VAR_NAME=$(echo "$ROLE"_DB_PASSWORD | tr '[:lower:]' '[:upper:]')
eval PASSWORD=\$$DB_PASSWORD_VAR_NAME

mysql -uroot -p$MYSQL_PASSWORD <<MYSQL_DB
create database if not exists $DB;
grant all privileges on $DB.* to '$MYSQL_USER'@'%' identified by '$PASSWORD';
grant all privileges on $DB.* to '$MYSQL_USER'@'localhost' identified by '$PASSWORD';
MYSQL_DB
done
