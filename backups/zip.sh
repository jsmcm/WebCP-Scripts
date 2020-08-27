#!/bin/bash

Password=`/usr/webcp/get_password.sh`

DomainID=$1
RandomPath=$2

if [ "$DomainID" == "" ]
then
        echo ""
        echo "Please supply args!!!"
        echo "zip.sh DomainID RandomPath"
	echo "eg, zip.sh 12 DSF324DF"
        exit
fi
			
if [ "$RandomPath" == "" ]
then
        echo ""
        echo "Please supply args!!!"
        echo "zip.sh DomainID RandomPath"
	echo "eg, zip.sh 12 DSF324DF"
        exit
fi
			
UserName=$(mysql cpadmin -u root -p${Password} -se "SELECT UserName FROM domains WHERE deleted = 0 AND id = $DomainID;")

if [ ! -d "/var/www/html/backups/tmp" ]; then
	mkdir /var/www/html/backups/tmp
fi

if [ ! -d "/var/www/html/backups/tmp/$RandomPath" ]; then
	mkdir /var/www/html/backups/tmp/$RandomPath
fi

cd /home/$UserName/home/$UserName/
/usr/bin/zip /var/www/html/backups/tmp/$RandomPath/${UserName}_home.zip public_html/ mail/ .passwd/ -r





