#!/bin/bash
Password=`/usr/webcp/get_password.sh`
User=`/usr/webcp/get_username.sh`
DB_HOST=`/usr/webcp/get_db_host.sh`

mysql cpadmin -u ${User} -p${Password} -h ${DB_HOST} -N -e "SELECT UserName, Uid FROM domains WHERE deleted = 0 AND domain_type = 'primary'" | while read UserName Uid; do

	if [ "${#UserName}" -gt "4" ]
        then
        	/usr/webcp/domains/mount.sh $UserName $Uid
	fi

done



