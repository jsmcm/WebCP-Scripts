#!/bin/sh

ifStart=`date '+%d'`
echo "ifStart = $ifStart"

if [ ! -f "/etc/csf/spamhaus.txt" ]
then
        echo "File does not exist"
        ifStart="01"
fi

if [ $ifStart == "01" ] || [ $ifStart == "08" ] || [ $ifStart == "15" ] || [ $ifStart == "22" ] || [ $ifStart == "28" ]
then

	echo "running"

	TempFile="csf_block_lists_update_"
	TempFile="$TempFile`date '+%Y%m%d'`"
	
	if [ -f "/var/www/html/webcp/tmp/$TempFile" ]
	then
		echo "Lock file exists, exiting";
		exit
	fi

	touch "/var/www/html/webcp/tmp/$TempFile"

	wget -O /etc/csf/spamhaus.txt -o /dev/null https://www.spamhaus.org/drop/drop.txt
	wget -O /etc/csf/spamhause.txt -o /dev/null https://www.spamhaus.org/drop/edrop.txt

	csf -r

fi

