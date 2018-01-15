#!/bin/bash

x=$(pgrep delemail.sh | wc -w)
if [ $x -gt 2 ]; then
        exit
fi

for FullFileName in /var/www/html/webcp/nm/*.dma; 
do

	if [ -f $FullFileName ]
	then	

		Dir=`cat $FullFileName`

		if [ "${#Dir}" -gt "8" ]
		then
		        rm -fr $Dir		
		fi
		rm -fr $FullFileName
	fi
	

done

