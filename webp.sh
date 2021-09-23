#!/bin/bash

if [ ! -d "/var/www/html/webcp/tmp/webp" ]
then
	echo "make dir"
	mkdir /var/www/html/webcp/tmp/webp/ -p
fi

for FullFileName in /var/www/html/webcp/nm/*.webp;
do

	#echo $FullFileName
        x=$FullFileName
        #echo "x: '$x'"
        y=${x%.webp}
        #echo "y: '$y'"
	unconvertedFilePath=${y##*/}
        echo "unconvertedFilePath: '$unconvertedFilePath'"
	
	user=`cat $FullFileName`
	echo "user: $user"

	finalFilePath=${unconvertedFilePath//_/\/}
	finalFilePath=${finalFilePath/public\/html/public_html}
        echo "finalFilePath: '$finalFilePath'"

	if [ -f "$finalFilePath" ]
	then
		cp $finalFilePath /var/www/html/webcp/tmp/webp/$unconvertedFilePath
		chown www-data.www-data /var/www/html/webcp/tmp/webp/ -R 
		wget -qO- http://127.0.0.1:8880/do-webp-on-demand.php?xsource=/var/www/html/webcp/tmp/webp/$unconvertedFilePath

		if [ -f "/var/www/html/webcp/tmp/webp/${unconvertedFilePath}.webp" ]
		then
			cp /var/www/html/webcp/tmp/webp/${unconvertedFilePath}.webp $finalFilePath.webp
			chown $user.$user $finalFilePath.webp
		fi

	fi

	rm /var/www/html/webcp/tmp/webp/$unconvertedFilePath
	rm /var/www/html/webcp/tmp/webp/$unconvertedFilePath.webp
	rm $FullFileName

done

