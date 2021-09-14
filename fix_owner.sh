#!/bin/bash
Password=`/usr/webcp/get_password.sh`
User=`/usr/webcp/get_username.sh`
DB_HOST=`/usr/webcp/get_db_host.sh`


for NextUN in $(mysql cpadmin -u ${User} -p${Password} -h ${DB_HOST} -se "SELECT DISTINCT(UserName) FROM domains WHERE deleted = 0 AND domain_type = 'primary';")
do


	echo "Got $NextUN";
	Path=$(mysql cpadmin -u ${User} -p${Password} -h ${DB_HOST} -se "SELECT path FROM domains WHERE deleted = 0 AND domain_type = 'primary' AND UserName = '$NextUN';")
	echo "Got $Path";

	if [ "${#Path}" -gt "6" ]
	then
		echo "chown $NextUN.$NextUN /home/$NextUN/home -R"
		chown $NextUN.$NextUN /home/$NextUN/home -R
		chgrp www-data /home/$NextUN/.passwd
	fi
	echo ""
done

