#!/bin/bash

x=$(pgrep delete_account.sh | wc -w)
if [ $x -gt 2 ]; then
        exit
fi

phpVersion=`php -v | grep PHP\ 7 | cut -d ' ' -f 2 | cut -d '.' -f1,2`
Password=`/usr/webcp/get_password.sh`
User=`/usr/webcp/get_username.sh`
DB_HOST=`/usr/webcp/get_db_host.sh`



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

		DomainName=$(mysql cpadmin -u ${User} -p${Password} -h ${DB_HOST} -se "SELECT fqdn FROM domains WHERE deleted = 1 AND id = $DomainID;")
		UserName=$(mysql cpadmin -u ${User} -p${Password} -h ${DB_HOST} -se "SELECT UserName FROM domains WHERE deleted = 1 AND id = $DomainID;")
		GroupID=$(mysql cpadmin -u ${User} -p${Password} -h ${DB_HOST} -se "SELECT Gid FROM domains WHERE deleted = 1 AND id = $DomainID;")
		UserID=$(mysql cpadmin -u ${User} -p${Password} -h ${DB_HOST} -se "SELECT Uid FROM domains WHERE deleted = 1 AND id = $DomainID;")

		rm -fr /etc/nginx/sites-enabled/$DomainName.conf
		rm -fr /var/lib/php/sessions/$UserName/

		
		for phpDirectory in /etc/php/*;
		do

        		phpVersion=${phpDirectory##*/}
			rm -fr /etc/php/$phpVersion/fpm/pool.d/$UserName.conf
			/usr/sbin/service php$phpVersion-fpm restart

		done
        	
		/usr/sbin/service nginx restart


                rm -fr /etc/letsencrypt/live/$DomainName*
                rm -fr /etc/letsencrypt/live/mail.$DomainName*
		rm -fr /etc/letsencrypt/archive/$DomainName*
		rm -fr /etc/letsencrypt/renewal/$DomainName*.conf 

		rm -fr /var/www/html/mail/domains/$DomainName

                rm -fr /etc/nginx/ssl/$DomainName.crt
                rm -fr /etc/nginx/ssl/$DomainName.csr
                rm -fr /etc/nginx/ssl/$DomainName.key

		if [ "${#UserName}" -gt "4" ]
		then
			/usr/webcp/domains/unmount.sh $UserName
			rm -fr /home/$UserName
			rm -fr /var/www/html/mail/domains/$DomainName
		fi


		rm -fr $FullFileName

		
		/usr/bin/crontab -r -u $UserName
		/usr/sbin/userdel $UserName
		/usr/sbin/groupdel $UserName

	
	fi
done


