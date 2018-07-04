#!/bin/bash

x=$(pgrep server.sh | wc -w)
if [ $x -gt 2 ]; then
        exit
fi

mkdir /var/www/html/webcp/server/tmp -p

df -B 1 /home > /var/www/html/webcp/server/tmp/diskspace.txt
free -m > /var/www/html/webcp/server/tmp/memory.txt
uptime > /var/www/html/webcp/server/tmp/load.txt

# Check for required folders in user's home dirs
for FullFileName in /home/*; 
do

	if [ -d $FullFileName ]
	then		
                x=$FullFileName
                UserName=${x##*/}

		if [ ! -d $FullFileName/.cron ]
		then
			#echo "Copying .cron to $UserName"
			cp -fr /etc/skel/.cron $FullFileName
			chown $UserName.$UserName $FullFileName/.cron -R
		fi

		if [ ! -d $FullFileName/.passwd ]
		then
			#echo "Copying .passwd to $UserName"
			cp -fr /etc/skel/.passwd $FullFileName
			chown $UserName.$UserName $FullFileName/.passwd -R
			chown $UserName.apache $FullFileName/.passwd
		fi
		
		if [ ! -d $FullFileName/.editor ]
		then
			ln -s /var/www/html/editor $FullFileName/.editor		
		fi

	fi

	#echo ""	
done

