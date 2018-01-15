#!/bin/bash

x=$(pgrep user_quota.sh | wc -w)
if [ $x -gt 2 ]; then
        exit
fi

for FullFileName in /var/www/html/webcp/nm/*.uquota; 
do

	if [ -f $FullFileName ]
	then	

		Dir=`cat $FullFileName`
		`$Dir`

		rm -fr $FullFileName
	fi
done


