#!/bin/bash

for FullFileName in /var/www/html/webcp/nm/*.add_spamassassin;
do

        if [ -f $FullFileName ]
        then

		BLOCK=""
		WARN=""
		SUBJECT=""
		LOCALPART=""
		DOMAIN=""
		
		while IFS="=" read -r key value; 
		do
		    	case "$key" in
		      		"block") BLOCK="${value//[$'\t\r\n ']}" ;;
			esac
		    	case "$key" in
		      		"warn") WARN="${value//[$'\t\r\n ']}" ;;
			esac
		    	case "$key" in
		      		"subject") SUBJECT="${value//[$'\t\r\n ']}" ;;
			esac
		    	case "$key" in
		      		"domain") DOMAIN="${value//[$'\t\r\n ']}" ;;
			esac
		    	case "$key" in
		      		"local_part") LOCALPART="${value//[$'\t\r\n ']}" ;;
			esac
		done < "$FullFileName"

		echo "local_part: '$LOCALPART'"
		echo "domain: '$DOMAIN'"
		echo "subject: '$SUBJECT'"
		echo "warn: '$WARN'"
		echo "block: '$BLOCK'"

		
		mkdir -p /var/www/html/mail/domains/$DOMAIN/$LOCALPART
		echo "$BLOCK" > /var/www/html/mail/domains/$DOMAIN/$LOCALPART/denyspamscore
		echo "$WARN" > /var/www/html/mail/domains/$DOMAIN/$LOCALPART/warnspamscore
		echo "$SUBJECT" > /var/www/html/mail/domains/$DOMAIN/$LOCALPART/warnspamsubject

		rm -fr $FullFileName	
	fi

done

