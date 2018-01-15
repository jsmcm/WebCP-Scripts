#!/bin/bash
DomainName=$1

if [ "$DomainName" == "" ]
then
	echo "Usage: get_csr.sh Domain"
	exit
fi

if [ -f "/etc/httpd/conf/ssl/$DomainName.csr" ] 
then
	CSR=`cat /etc/httpd/conf/ssl/$DomainName.csr`
	echo $CSR
fi
