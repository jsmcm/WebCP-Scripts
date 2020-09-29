#!/bin/bash
DomainName=$1

if [ "$DomainName" == "" ]
then
	echo "Usage: get_csr.sh Domain"
	exit
fi

if [ -f "/etc/nginx/ssl/$DomainName.csr" ] 
then
	CSR=`cat /etc/nginx/ssl/$DomainName.csr`
	echo $CSR
fi
