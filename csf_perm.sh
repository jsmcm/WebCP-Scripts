#!/bin/bash

csf=`md5sum /etc/csf/csf.deny | cut -d' ' -f 1`
echo "$csf"

if [ -f /var/www/html/webcp/fail2ban/perm.dat ]
then
	perm=`md5sum /var/www/html/webcp/fail2ban/perm.dat | cut -d' ' -f 1`
	echo "$perm"

	if [ "$csf" != "$perm" ]
	then

		csf=`stat -c %Y /etc/csf/csf.deny | cut -d ' ' -f1`
		perm=`stat -c %Y /var/www/html/webcp/fail2ban/perm.dat | cut -d ' ' -f1`

		if [ $csf -gt $perm ]
		then
			cp /etc/csf/csf.deny /var/www/html/webcp/fail2ban/perm.dat
			chown apache.apache /var/www/html/webcp/fail2ban/perm.dat
			chmod 755 /var/www/html/webcp/fail2ban/perm.dat
		else
			cp /var/www/html/webcp/fail2ban/perm.dat /etc/csf/csf.deny
			chown root.root /etc/csf/csf.deny
			chmod 600 /etc/csf/csf.deny
	
			/etc/csf/csf.pl -r
		fi

	fi
else
	cp /etc/csf/csf.deny /var/www/html/webcp/fail2ban/perm.dat
	chown apache.apache /var/www/html/webcp/fail2ban/perm.dat
	chmod 755 /var/www/html/webcp/fail2ban/perm.dat
fi
