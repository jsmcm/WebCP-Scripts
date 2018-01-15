#!/bin/bash

FullFileName=/var/www/html/webcp/nm/whitelist

	if [ -e $FullFileName ]
	then	
		rm -fr /etc/exim/whitelist
		mv $FullFileName /etc/exim/whitelist                
	fi

exit
