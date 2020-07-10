#!/bin/bash

x=$(pgrep do_change_root.sh | wc -w)
if [ $x -gt 2 ]; then
        exit
fi

Password=`/usr/webcp/get_password.sh`

if [ -f "/var/www/html/webcp/nm/root.password" ]
then

	echo "File exists"

	/usr/webcp/mysql/pureftpd_root_password.sh $Password  
	
	rm -fr /var/www/html/webcp/nm/root.password

fi

echo "done"

