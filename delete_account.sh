#!/bin/bash

x=$(pgrep delete_account.sh | wc -w)
if [ $x -gt 2 ]; then
        exit
fi

Password=`/usr/webcp/get_password.sh`

for FullFileName in /var/www/html/webcp/nm/*.delete_domain; 
do

	if [ -f $FullFileName ]
	then	
		##echo $FullFileName
		x=$FullFileName
                echo "x: '$x'"
		y=${x%.delete_domain}
                echo "y: '$y'"
		DomainID=${y##*/}
                echo "file: '$DomainID'"

		DomainName=$(mysql cpadmin -u root -p${Password} -se "SELECT fqdn FROM domains WHERE deleted = 1 AND id = $DomainID;")
		UserName=$(mysql cpadmin -u root -p${Password} -se "SELECT UserName FROM domains WHERE deleted = 1 AND id = $DomainID;")
		GroupID=$(mysql cpadmin -u root -p${Password} -se "SELECT Gid FROM domains WHERE deleted = 1 AND id = $DomainID;")
		UserID=$(mysql cpadmin -u root -p${Password} -se "SELECT Uid FROM domains WHERE deleted = 1 AND id = $DomainID;")

                rm -fr /etc/letsencrypt/live/$DomainName*
                rm -fr /etc/letsencrypt/archive/$DomainName*
                rm -fr /etc/letsencrypt/renewal/$DomainName*.conf 

                rm -fr /etc/httpd/conf/ssl/$DomainName.crt
                rm -fr /etc/httpd/conf/ssl/$DomainName.csr
                rm -fr /etc/httpd/conf/ssl/$DomainName.key

		if [ "${#UserName}" -gt "4" ]
		then
			rm -fr /home/$UserName
		fi


		rm -fr /etc/php/7.0/fpm/pool.d/$UserName.conf
		rm -fr /etc/nginx/sites-enabled/$DomainName.conf
		rm -fr $FullFileName

        	service nginx reload
		service php7.0-fpm reload
		
		/usr/bin/crontab -r -u $UserName
		userdel $UserName
		groupdel $UserName

	
	fi
done


