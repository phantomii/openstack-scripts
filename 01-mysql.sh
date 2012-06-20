#!/bin/bash

. $(dirname $(readlink -f $0))/00-lib.sh

check_root

MYSQL_PKG=mysql-server-5.5

# Seed configuration with mysql password so that apt-get install doesn't
# prompt us for a password upon install.
cat <<MYSQL_PRESEED | sudo debconf-set-selections
$MYSQL_PKG mysql-server/root_password password $MYSQL_PASSWORD
$MYSQL_PKG mysql-server/root_password_again password $MYSQL_PASSWORD
$MYSQL_PKG mysql-server/start_on_boot boolean true
MYSQL_PRESEED

# while ``.my.cnf`` is not needed for openstack to function, it is useful
# as it allows you to access the mysql databases via ``mysql nova`` instead
 # of having to specify the username/password each time.
if [[ ! -e $HOME/.my.cnf ]]; then
cat <<EOF >$HOME/.my.cnf
[client]
user=root
password=$MYSQL_PASSWORD
host=localhost
EOF
chmod 0600 $HOME/.my.cnf
fi

# Install and start mysql-server
apt-get -y install $MYSQL_PKG
# Update the DB to give user ‘$MYSQL_USER’@’%’ full control of the all databases:
sudo mysql -uroot -p$MYSQL_PASSWORD -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' identified by '$MYSQL_PASSWORD';"

# Update ``my.cnf`` for some local needs and restart the mysql service
MY_CONF=/etc/mysql/my.cnf

# Change ‘bind-address’ from localhost (127.0.0.1) to any (0.0.0.0)
sudo sed -i "/^bind-address/s/127.0.0.1/$MYSQL_HOST/g" $MY_CONF

# Set default db type to InnoDB
if grep -q "default-storage-engine" $MY_CONF; then
	# Change it
        sudo bash -c "source $TOP_DIR/functions; iniset $MY_CONF mysqld default-storage-engine InnoDB"
else
        # Add it
        sudo sed -i -e "/^\[mysqld\]/ a default-storage-engine = InnoDB" $MY_CONF
fi

echo "Restarting MySQL"

service mysql restart

echo "Creating users and databases"

for ROLE in nova keystone glance
do
DB=$ROLE
MYSQL_USER=$ROLE
mysql -uroot -p$MYSQL_PASSWORD <<MYSQL_DB
create database if not exists $DB;
grant all privileges on $DB.* to '$MYSQL_USER'@'%' identified by '$MYSQL_PASSWORD';
grant all privileges on $DB.* to '$MYSQL_USER'@'localhost' identified by '$MYSQL_PASSWORD';
MYSQL_DB
done
