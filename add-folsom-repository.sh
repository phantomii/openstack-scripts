#!/bin/bash

. $(dirname $(readlink -f $0))/00-lib.sh

check_root

echo deb http://ubuntu-cloud.archive.canonical.com/ubuntu precise-updates/folsom main >> /etc/apt/sources.list.d/folsom.list &&	apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 5EDB1B62EC4926EA
