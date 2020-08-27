#!/bin/bash

Password=`/usr/webcp/get_password.sh`
domainName=`hostname`

echo "127.0.1.1 $domainName" > /etc/hosts
echo "127.0.0.1 localhost" >> /etc/hosts

#for nextDomain in $(mysql cpadmin -u root -p${Password} -se "SELECT fqdn FROM domains WHERE deleted = 0;")
#do
#	echo "127.0.1.1 $nextDomain" >> /etc/hosts
#done
