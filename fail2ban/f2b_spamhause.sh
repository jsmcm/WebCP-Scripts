#!/bin/bash


ifStart=`date '+%d'`
echo "ifStart = $ifStart"

if [ "$ifStart" == "01" ] || [ "$ifStart" == "08" ] || [ "$ifStart" == "15" ] || [ "$ifStart" == "22" ] || [ "$ifStart" == "28" ]
then

	echo "running"
	mkdir -p /var/www/html/webcp/tmp

	TempFile="fail2ban_block_lists_update_"
	TempFile="$TempFile`date '+%Y%m%d'`"
	
	if [ -f "/var/www/html/webcp/tmp/$TempFile" ]
	then
		echo "Lock file exists, exiting";
		exit
	fi

	touch "/var/www/html/webcp/tmp/$TempFile"

	wget -O /var/www/html/webcp/tmp/spamhaus.txt -o /dev/null https://www.spamhaus.org/drop/drop.txt
	if [ -f "/var/www/html/webcp/tmp/spamhaus.txt" ]
	then

		while read line
		do

			if [ "${line:0:1}" != ";" ] 
			then
				echo "line: '${line% ;*}'"

				fail2ban-client set webcp-spamhause banip ${line% ;*}
			fi 

		done < /var/www/html/webcp/tmp/spamhaus.txt		
		rm -fr /var/www/html/webcp/tmp/spamhaus.txt		
	fi
		
	wget -O /var/www/html/webcp/tmp/spamhause.txt -o /dev/null https://www.spamhaus.org/drop/edrop.txt
	if [ -f "/var/www/html/webcp/tmp/spamhause.txt" ]
	then

		while read line
		do

			if [ "${line:0:1}" != ";" ] 
			then
				echo "line: '${line% ;*}'"

				fail2ban-client set webcp-spamhause banip ${line% ;*}
			fi 

		done < /var/www/html/webcp/tmp/spamhause.txt		
		rm -fr /var/www/html/webcp/tmp/spamhause.txt		
	fi
		



fi

