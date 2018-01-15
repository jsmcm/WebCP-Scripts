#!/bin/bash

x=$(pgrep redo_httpd_conf.sh | wc -w)
if [ $x -gt 2 ]; then
        exit
fi


Password=`cat /usr/webcp/password`

SharedIP=""
SharedIP=$(mysql cpadmin -u root -p${Password} -se "SELECT IFNULL(MIN(option_value), '*') FROM dns_options WHERE option_name = 'ip' AND deleted = 0 AND extra1 = 'shared' LIMIT 1;")


	OldFile="/usr/webcp/templates/httpd.conf"
	NewFile="/etc/httpd/conf/httpd.conf"

	cat $OldFile | sed "s/NameVirtualHost \*:/NameVirtualHost $SharedIP:/" > $NewFile
        
	/etc/init.d/httpd graceful

	
