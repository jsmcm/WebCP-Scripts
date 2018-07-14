#!/bin/bash

x=$(pgrep catchall.sh | wc -w)
if [ $x -gt 2 ]; then
        exit
fi


for FullFileName in /var/www/html/webcp/nm/*.catchall; 
do

	if [ -f $FullFileName ]
	then	

		x=$FullFileName
		y=${x%.catchall}
		DomainName=${y##*/}
               	DomainName=${DomainName%_*}
		
		EmailAddress=`cat $FullFileName`

		echo "DomainName: '$DomainName'"
		echo "EmailAddress: '$EmailAddress'"

		if [ "$EmailAddress" == "" ]
		then
			echo "removing catchall"
			if [ -f "/var/www/html/mail/domains/$DomainName/catchall" ]
			then
				rm -fr /var/www/html/mail/domains/$DomainName/catchall
			fi
		else
			echo "$EmailAddress" > /var/www/html/mail/domains/$DomainName/catchall
		fi 

		rm -fr $FullFileName
	fi
	

done

