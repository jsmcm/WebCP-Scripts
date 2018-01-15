#!/bin/bash


UserName=$1
RandomPath=$2

if [ "$UserName" == "" ]
then
        echo ""
        echo "Please supply args!!!"
        echo "mailtar.gz.sh UserName RandomPath"
	echo "eg, mailtar.gz.sh examplec DSF324DF"
        exit
fi
			
if [ "$RandomPath" == "" ]
then
        echo ""
        echo "Please supply args!!!"
        echo "mailtar.gz.sh UserName RandomPath"
	echo "eg, mailtar.gz.sh examplec DSF324DF"
        exit
fi
			

if [ ! -d "/var/www/html/webcp/backups/tmp" ]; then
	mkdir /var/www/html/webcp/backups/tmp
fi

if [ ! -d "/var/www/html/webcp/backups/tmp/$RandomPath" ]; then
	mkdir /var/www/html/webcp/backups/tmp/$RandomPath
fi

cd /home/$UserName/
nice /bin/tar cf /var/www/html/webcp/backups/tmp/$RandomPath/${UserName}_mail.tar mail/





