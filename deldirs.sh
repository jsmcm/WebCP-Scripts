#!/bin/bash

x=$(pgrep deldirs.sh | wc -w)
if [ $x -gt 2 ]; then
        exit
fi

Restart=0

for FullFileName in /var/www/html/webcp/nm/*.dml; 
do

	if [ -f $FullFileName ]
	then	

		Restart=1

		##echo $FullFileName
		x=$FullFileName
		y=${x%.dml}
		file=${y##*/}
                ##echo "file: $file"

		

		/usr/bin/crontab -r -u $file
		echo "userdel $file"
		userdel $file

		echo "groupdel $file"
		groupdel $file
		
		if [ "${#file}" -gt "4" ]
		then
			##echo "/home/$file"
			rm -fr /home/$file
		fi
		
		# Delete the vhosts
		/usr/webcp/delvhost.sh

		rm -fr $FullFileName
	fi
	

done

	if [ "$Restart" == "1" ]
	then
		/etc/init.d/httpd graceful
	fi
