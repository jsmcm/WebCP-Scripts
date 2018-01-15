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
		echo "Got $Line"

		IN=$line

		arr=(${IN//,/ })

		x=${arr[0]}
		y=${arr[1]}
	
		echo "x = $x"
		echo "y = $y"

		fail2ban-client set manual banip $x

	done </var/www/html/webcp/fail2ban/tmp/add.working

	rm -fr /var/www/html/webcp/fail2ban/tmp/add.working
fi
