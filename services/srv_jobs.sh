#!/bin/bash

x=$(pgrep srv_jobs.sh | wc -w)
if [ $x -gt 2 ]; then
	exit
fi

/usr/webcp/services/check_exim.sh
/usr/webcp/services/check_clamd.sh
/usr/webcp/services/check_dovecot.sh
/usr/webcp/services/check_nginx.sh
/usr/webcp/services/check_mysqld.sh
/usr/webcp/services/check_pure-ftpd.sh

if [ -f "/var/www/html/webcp/nm/modsec_gw" ] 
then
	/usr/webcp/modsec_gw.sh
	rm -fr /var/www/html/webcp/nm/modsec_gw

	/etc/init.d/httpd graceful
fi

/usr/webcp/update/update.sh

