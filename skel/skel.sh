#!/bin/bash

rm -fr /etc/skel/public_html/*

if [ ! -d "/etc/skel/public_html" ]
then
	mkdir /etc/skel/public_html
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
	cp -fr /var/www/html/webcp/skel/public_html/* /etc/skel/public_html
else
	echo "using failsafe"
	cp -fr /var/www/html/webcp/skel/failsafe /etc/skel/public_html/index.php
fi

exit




