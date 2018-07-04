#!/usr/bin/env bash

if [ -f /var/www/html/webcp/fail2ban/tmp/add.working ]
then
	# still busy with previous actions
	exit
fi

echo "Checking add.ban"

if [ -f /var/www/html/webcp/fail2ban/tmp/add.ban ]
then

	mv /var/www/html/webcp/fail2ban/tmp/add.ban /var/www/html/webcp/fail2ban/tmp/add.working
	while read line
	do
		echo "Got $line"

		fail2ban-client set webcp-manual banip $line

	done </var/www/html/webcp/fail2ban/tmp/add.working

	rm -fr /var/www/html/webcp/fail2ban/tmp/add.working
fi
