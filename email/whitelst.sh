#!/bin/bash

FullFileName=/var/www/html/webcp/nm/whitelist

	if [ -e $FullFileName ]
	then	
		rm -fr /var/www/html/mail/whitelist
		mv $FullFileName /var/www/html/mail/whitelist                
	fi

