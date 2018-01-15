#!/usr/bin/env bash
Password=`cat /usr/webcp/password`

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
		echo $line
		csf -tr $line
		$(mysql cpadmin -u root -p${Password} -se "DELETE FROM csf WHERE ip = '$line';")

	done </var/www/html/webcp/fail2ban/tmp/remove.working

	rm -fr /var/www/html/webcp/fail2ban/tmp/remove.working
fi
