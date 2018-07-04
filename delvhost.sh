#!/bin/bash

for FullFileName in /var/www/html/webcp/nm/*.dvh; 
do

	if [ -f $FullFileName ]
	then	
		##echo $FullFileName
		x=$FullFileName
		y=${x%.dvh}
		DomainName=${y##*/}
                echo "file: $DomainName"

		UserName=`cat $FullFileName`

		echo "UserName: $UserName"
		echo "DomainName: $DomainName"

		rm -fr /etc/nginx/sites-enabled/$DomainName.conf
		rm -fr /etc/php/7.0/fpm/pool.d/$UserName.conf
		rm -fr $FullFileName
	fi
done

