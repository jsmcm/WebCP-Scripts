#!/bin/bash

BLOCK=""
WARN=""
SUBJECT=""
LOCALPART=""
DOMAIN=""

while IFS="=" read -r key value; 
do
    	case "$key" in
      		"block") BLOCK="$value" ;;
	esac
    	case "$key" in
      		"warn") WARN="$value" ;;
	esac
    	case "$key" in
      		"subject") SUBJECT="$value" ;;
	esac
    	case "$key" in
      		"domain") DOMAIN="$value" ;;
	esac
    	case "$key" in
      		"local_part") LOCALPART="$value" ;;
	esac
done < "/var/www/html/webcp/nm/john@testsix.demoserver.co.za.add_spamassassin"

echo "local_part: '$LOCALPART'"
echo "domain: '$DOMAIN'"

#echo "$BLOCK" > /var/www/html/mail/domains/$domain/$email/denyspamscore
