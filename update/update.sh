#!/bin/bash

# don't want to run this on dev or machines with git
if [ -f "/var/www/html/webcp/.git/config" ]
then
	exit
fi


CurrentTime="$(date +"%Y-%m-%d_%H-%M-%S")"


if [ -f "/var/www/html/webcp/tmp/scripts.zip" ]
then
	cd /usr/
	zip backups_$CurrentTime.zip webcp -r
	rm -fr /usr/scripts.zip
	mv /var/www/html/webcp/tmp/scripts.zip /usr/scripts.zip
	unzip -o scripts.zip
	rm -fr /usr/scripts.zip
	chmod 755 /usr/webcp -R
fi



if [ -f "/var/www/html/webcp/tmp/webcp.zip" ]
then
	cd /var/www/html/
	zip webcp_$CurrentTime.zip webcp -r
	mv /var/www/html/webcp/tmp/webcp.zip /var/www/html/
	unzip -o webcp.zip
	rm -fr /var/www/html/webcp.zip
	chown www-data.www-data /var/www/html/webcp -R
fi



MD51=""
if [ -f "/tmp/webcp/exim4.conf.zip" ]
then
        MD51=`md5sum /tmp/webcp/exim4.conf.zip | awk '{ print $1 }'`
fi


cd /tmp/webcp
wget -N http://webcp.pw/api/downloads/2.0.0/config/exim4.conf.zip	

if [ -f "/tmp/webcp/exim4.conf.zip" ]
then
        MD52=`md5sum /tmp/webcp/exim4.conf.zip | awk '{ print $1 }'`

	if [ "$MD51" != "$MD52" ]
	then
		cd /etc/exim4
		rm -fr /etc/exim4/exim4.conf
		cp /tmp/webcp/exim4.conf.zip /etc/exim4
		unzip /etc/exim4/exim4.conf.zip
		rm -fr /etc/exim4/exim4.conf.zip
		service exim4 restart
	fi
fi

