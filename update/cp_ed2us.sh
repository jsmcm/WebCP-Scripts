#!/bin/bash

# Called automatically by update.sh

Password=`/usr/webcp/get_password.sh`

if [ ! -f "/etc/skel/etc_skel_editor.zip" ]
then
	cd /etc/skel
	zip etc_skel_editor.zip .editor -r
fi

for NextUN in $(mysql cpadmin -u root -p${Password} -se "SELECT UserName FROM domains WHERE deleted = 0 AND domain_type = 'primary';")
do
	if [ "${#NextUN}" -gt "1" ]
	then	
		cd /home/$NextUN
		cp /etc/skel/etc_skel_editor.zip /home/$NextUN
		unzip -o /home/$NextUN/etc_skel_editor.zip
		rm -fr /home/$NextUN/etc_skel_editor.zip
		chmod 755 /home/$NextUN/.editor -R
		chown $NextUN.$NextUN /home/$NextUN/.editor -R
	fi
done

