#!/bin/bash

x=$(pgrep php_config.sh | wc -w)
if [ $x -gt 2 ]; then
        exit
fi


for FullFileName in /var/www/html/webcp/nm/*.phpconfig; 
do

	if [ -f $FullFileName ]
	then	

		echo $FullFileName
		x=$FullFileName
                echo "x: '$x'"
		y=${x%.phpconfig}
                echo "y: '$y'"
		phpVersion=${y##*/}
                echo "phpVersion: '$phpVersion'"

		rm -fr /etc/php/$phpVersion/fpm/php.ini

		cp $FullFileName /etc/php/$phpVersion/fpm/php.ini

		rm -fr $FullFileName
	fi

done


/usr/sbin/service nginx reload
/usr/sbin/service php$phpVersion-fpm reload

