#!/bin/bash

for FullFileName in /var/www/html/webcp/nm/*.delete_spamassassin;
do

        if [ -f $FullFileName ]
        then

		LOCALPART=""
		DOMAIN=""
		
		while IFS="=" read -r key value; 
		do
		    	case "$key" in
		      		"domain") DOMAIN="${value//[$'\t\r\n ']}" ;;
			esac
		    	case "$key" in
		      		"local_part") LOCALPART="${value//[$'\t\r\n ']}" ;;
			esac
		done < "$FullFileName"

		echo "local_part: '$LOCALPART'"
		echo "domain: '$DOMAIN'"

		if [ -f "/var/www/html/mail/domains/$DOMAIN/$LOCALPART/denyspamscore" ]
		then
			rm -fr /var/www/html/mail/domains/$DOMAIN/$LOCALPART/denyspamscore
		fi

		if [ -f "/var/www/html/mail/domains/$DOMAIN/$LOCALPART/warnspamscore" ]
		then
			rm -fr /var/www/html/mail/domains/$DOMAIN/$LOCALPART/warnspamscore
		fi


		if [ -f "/var/www/html/mail/domains/$DOMAIN/$LOCALPART/warnspamsubject" ]
		then
			rm -fr /var/www/html/mail/domains/$DOMAIN/$LOCALPART/warnspamsubject
		fi

		rm -fr $FullFileName	
	fi

done

