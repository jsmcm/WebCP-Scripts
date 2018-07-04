#!/bin/bash

x=$(pgrep suspension.sh | wc -w)
if [ $x -gt 2 ]; then
        exit
fi

Reload=0

for FullFileName in /var/www/html/webcp/nm/*.suspend; 
do

	if [ -f $FullFileName ]
	then	
		echo $FullFileName
		x=$FullFileName
                echo "x: '$x'"
		y=${x%.suspend}
                echo "y: '$y'"
		DomainName=${y##*/}
                echo "DomainName: '$DomainName'"

		if [ "${#DomainName}" -gt "3" ]
		then
			Reload=1
			if [ -f "/etc/nginx/sites-enabled/$DomainName.conf" ]
			then
				mv /etc/nginx/sites-enabled/$DomainName.conf /etc/nginx/sites-suspended/$DomainName.conf
			fi

			echo "server {" > /etc/nginx/sites-enabled/$DomainName.conf
			echo "listen 443;" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "server_name testone.demoserver.co.za;" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "return 301 http://$DomainName;" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "}" >> /etc/nginx/sites-enabled/$DomainName.conf


			echo "server {" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "listen 80;" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "server_name testone.demoserver.co.za;" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "root /var/www/html/suspended;" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "location / {" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "rewrite ^ /index.html break;" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "}" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "}" >> /etc/nginx/sites-enabled/$DomainName.conf
	
			rm -fr $FullFileName
		fi
	fi

done


for FullFileName in /var/www/html/webcp/nm/*.unsuspend; 
do

	if [ -f $FullFileName ]
	then	
		echo $FullFileName
		x=$FullFileName
                echo "x: '$x'"
		y=${x%.unsuspend}
                echo "y: '$y'"
		DomainName=${y##*/}
                echo "DomainName: '$DomainName'"

		
	
			if [ -f "/etc/nginx/sites-suspended/$DomainName.conf" ]
			then
				Reload=1
				mv /etc/nginx/sites-suspended/$DomainName.conf /etc/nginx/sites-enabled/$DomainName.conf
			fi
	
	
			rm -fr $FullFileName
	fi

done

if [ $Reload == 1 ] 
then
	service nginx reload
fi


echo "Done"
