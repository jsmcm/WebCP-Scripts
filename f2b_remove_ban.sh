#!/usr/bin/env bash

if [ -f /var/www/html/webcp/fail2ban/tmp/remove.working ]
then
	rm -fr /var/www/html/webcp/fail2ban/tmp/remove.working
fi

if [ -f /var/www/html/webcp/fail2ban/tmp/remove.ban ]
then

	mv /var/www/html/webcp/fail2ban/tmp/remove.ban /var/www/html/webcp/fail2ban/tmp/remove.working
	while read line
	do

		IN=$line

		arr=(${IN//,/ })

		x=${arr[0]}
		y=${arr[1]}

		fail2ban-client set $y unbanip $x

	done </var/www/html/webcp/fail2ban/tmp/remove.working

	rm -fr /var/www/html/webcp/fail2ban/tmp/remove.working
fi
