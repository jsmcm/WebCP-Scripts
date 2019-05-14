#!/bin/bash

# we don't want this script to run on our dev machines
if [ -f "/var/www/html/dev" ]
then
	echo "exiting"
	exit
fi

phpVersion=`php -v | grep PHP\ 7 | cut -d ' ' -f 2 | cut -d '.' -f1,2`

## SCRIPTS ##
cd /usr/webcp
git pull origin master


## WEBCP ##
cd /var/www/html/webcp

if [ "$phpVersion" == "7.0" ]
then
	git checkout 7.0
	git pull origin 7.0
else
	git checkout 7.1
	git pull origin 7.1
fi

chown www-data.www-data /var/www/html/webcp -R



## EDITOR ##
cd /var/www/html/editor
git pull origin master
chown www-data.www-data /var/www/html/editor -R
