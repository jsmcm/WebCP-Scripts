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
			

if [ ! -d "/var/www/html/backups/tmp" ]; then
	mkdir /var/www/html/backups/tmp
fi

if [ ! -d "/var/www/html/backups/tmp/$RandomPath" ]; then
	mkdir /var/www/html/backups/tmp/$RandomPath
fi

cd /home/$UserName/home/
nice /bin/tar cf /var/www/html/backups/tmp/$RandomPath/${UserName}_mail.tar mail/





