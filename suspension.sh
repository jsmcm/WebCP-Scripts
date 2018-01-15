#!/bin/bash

x=$(pgrep suspension.sh | wc -w)
if [ $x -gt 2 ]; then
        exit
fi

HostName=`hostname`

for FullFileName in /var/www/html/webcp/nm/*.suspend; 
do

	if [ -f $FullFileName ]
	then	
		echo $FullFileName
		x=$FullFileName
                echo "x: '$x'"
		y=${x%.suspend}
                echo "y: '$y'"
		DomainUserName=${y##*/}
                echo "DomainUserName: '$DomainUserName'"

		if [ "${#DomainUserName}" -gt "1" ]
		then
			if [ -f "/home/$DomainUserName/public_html/.htaccess" ]
			then
				mv /home/$DomainUserName/public_html/.htaccess /home/$DomainUserName/public_html/suspended.htaccess
			fi
	
			echo "RedirectMatch .* http://$HostName:10025/suspended" >> /home/$DomainUserName/public_html/.htaccess
			chown $DomainUserName.$DomainUserName /home/$DomainUserName/public_html/.htaccess
	
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
		DomainUserName=${y##*/}
                echo "DomainUserName: '$DomainUserName'"

		
		if [ "${#DomainUserName}" -gt "1" ]
		then
			if [ "${#DomainUserName}" -gt "4" ]
			then
				rm -fr /home/$DomainUserName/public_html/.htaccess
			fi
	
			if [ -f "/home/$DomainUserName/public_html/suspended.htaccess" ]
			then
				mv /home/$DomainUserName/public_html/suspended.htaccess /home/$DomainUserName/public_html/.htaccess
			fi
	
			chown $DomainUserName.$DomainUserName /home/$DomainUserName/public_html/.htaccess
	
			rm -fr $FullFileName
		fi
	fi

done


echo "Done"
exit
