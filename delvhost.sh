#!/bin/bash

phpVersion=`php -v | grep PHP\ 7 | cut -d ' ' -f 2 | cut -d '.' -f1,2`

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
		rm -fr /etc/php/$phpVersion/fpm/pool.d/$UserName.conf
		rm -fr /var/lib/php/sessions/$UserName/
		rm -fr $FullFileName
	fi
done

