#!/bin/bash

x=$(pgrep deleteforwardaddress.sh | wc -w)
if [ $x -gt 2 ]; then
        exit
fi


for FullFileName in /var/www/html/webcp/nm/*.delete_forward_address; 
do

	if [ -f $FullFileName ]
	then	

		LOCAL_PART=""
		DOMAIN_NAME=""

		while IFS="=" read -r key value; 
		do
		        case "$key" in
		                "LOCAL_PART") LOCAL_PART="$value" ;;
		        esac
		        case "$key" in
		                "DOMAIN_NAME") DOMAIN_NAME="$value" ;;
		        esac
		done < "$FullFileName"

	LOCAL_PART="${LOCAL_PART//$'\n'}"
	LOCAL_PART="${LOCAL_PART//$'\r'}"

	DOMAIN_NAME="${DOMAIN_NAME//$'\n'}"
	DOMAIN_NAME="${DOMAIN_NAME//$'\r'}"

		echo "LOCAL_PART: $LOCAL_PART"
		echo "DOMAIN_NAME: $DOMAIN_NAME"

		rm -fr /var/www/html/mail/domains/$DOMAIN_NAME/forward/$LOCAL_PART

		rm -fr $FullFileName
	fi

done

