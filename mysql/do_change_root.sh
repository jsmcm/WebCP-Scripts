#!/bin/bash

x=$(pgrep do_change_root.sh | wc -w)
if [ $x -gt 2 ]; then
        exit
fi

if [ -f "/var/www/html/webcp/nm/root.password" ]
then

	echo "File exists"
	Password=`cat /var/www/html/webcp/nm/root.password`

	/usr/webcp/mysql/pureftpd_root_password.sh $Password  
	/usr/webcp/mysql/webcp_root_password.sh $Password
	
	rm -fr /var/www/html/webcp/nm/root.password
fi

echo "done"

