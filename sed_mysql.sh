#!/bin/bash

node_hostname=`hostname`
sed -i 's/node_hostname/'${node_hostname}'/' /etc/my.cnf

node_ip=`ifconfig eth0 | awk -F ' *|:' '/inet addr/{print $4}'`
sed -i 's/node_ip/'${node_ip}'/' /etc/my.cnf
