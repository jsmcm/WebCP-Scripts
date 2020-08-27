#!/bin/bash

UserName=$1
RandomPath=$2

if [ "$UserName" == "" ]
then
        echo ""
        echo "Please supply args!!!"
        echo "webtar.gz.sh DomainUserName RandomPath"
	echo "eg, webtar.gz.sh examplec DSF324DF"
        exit
fi
			
if [ "$RandomPath" == "" ]
then
        echo ""
        echo "Please supply args!!!"
        echo "webtar.gz.sh DomainUserName RandomPath"
	echo "eg, webtar.gz.sh examplec DSF324DF"
        exit
fi
			

if [ ! -d "/var/www/html/backups/tmp" ]; then
	mkdir /var/www/html/backups/tmp
fi

if [ ! -d "/var/www/html/backups/tmp/$RandomPath" ]; then
	mkdir /var/www/html/backups/tmp/$RandomPath
fi

cd /home/${UserName}/home
#/bin/tar cf /var/www/html/backups/tmp/$RandomPath/${UserName}_web.tar public_html/ .passwd/
nice /bin/tar cf /var/www/html/backups/tmp/$RandomPath/${UserName}_web.tar ${UserName}/ --exclude=mail  
