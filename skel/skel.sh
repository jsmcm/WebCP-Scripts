#!/bin/bash

rm -fr /etc/skel/home/public_html/*

if [ ! -d "/etc/skel/home/public_html" ]
then
	mkdir /etc/skel/home/public_html -p
fi

UseFailSafe=1
if [ -f "/var/www/html/webcp/skel/public_html/index.php" ]
then
	UseFailSafe=0
fi

if [ -f "/var/www/html/webcp/skel/public_html/index.html" ]
then
	UseFailSafe=0
fi

if [ -f "/var/www/html/webcp/skel/public_html/index.htm" ]
then
	UseFailSafe=0
fi


if [ $UseFailSafe -eq 0 ]
then
	echo "Using ph"
	cp -fr /var/www/html/webcp/skel/public_html/* /etc/skel/home/public_html
else
	echo "using failsafe"
	cp -fr /var/www/html/webcp/skel/failsafe /etc/skel/home/public_html/index.php
fi

