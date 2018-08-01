#!/bin/bash

# we don't want this script to run on our dev machines
if [ -f "/var/www/html/dev" ]
then
echo "exiting"
	exit
fi

## SCRIPTS ##
cd /usr/webcp
git pull origin master
chmod 755 /usr/webcp -R



## WEBCP ##
cd /var/www/html/webcp
git pull origin master
chown www-data.www-data /var/www/html/webcp -R
