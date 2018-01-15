#!/bin/sh
Password=$1

if [ -z "$Password" ]; then
	echo "Please supply the password"
  	exit 1
fi

cat /usr/webcp/templates/exim_top.txt > /etc/exim/exim.conf
echo "hide mysql_servers = localhost/cpadmin/root/$Password" >> /etc/exim/exim.conf
cat /usr/webcp/templates/exim_bottom.txt >> /etc/exim/exim.conf

/etc/init.d/exim restart

