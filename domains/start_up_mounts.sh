#!/bin/bash
Password=`/usr/webcp/get_password.sh`


mysql cpadmin -u root -p${Password} -N -e "SELECT UserName, Uid FROM domains WHERE deleted = 0 AND domain_type = 'primary'" | while read UserName Uid; do

	if [ "${#UserName}" -gt "4" ]
        then
        	/usr/webcp/domains/mount.sh $UserName $Uid
	fi

done



