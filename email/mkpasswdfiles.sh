#!/bin/bash

Password=`/usr/webcp/get_password.sh`
User=`/usr/webcp/get_username.sh`
DB_HOST=`/usr/webcp/get_db_host.sh`

DomainName=$1
UserName=$2
GroupID=$3
UserID=$4


if [ -f "/var/www/html/mail/domains/$DomainName/passwd" ]
then
	rm -fr /var/www/html/mail/domains/$DomainName/passwd
fi
	
if [ -f "/var/www/html/mail/domains/$DomainName/dovecot-passwd" ]
then
	rm -fr /var/www/html/mail/domains/$DomainName/dovecot-passwd
fi

mysql cpadmin -u ${User} -p${Password} -h ${DB_HOST} -N -e "SELECT local_part, fqdn, password FROM mailboxes, domains WHERE domain_id = domains.id AND domain_user_name='$UserName' AND mailboxes.active=1" | while read local_part fqdn password; do

	if [ ! -d "/var/www/html/mail/domains/$fqdn" ]
	then
		mkdir /var/www/html/mail/domains/$fqdn
	fi
				
	echo "$local_part@$fqdn:$password" >> /var/www/html/mail/domains/$fqdn/passwd
	echo "$local_part@$fqdn:$password"

	echo "$local_part:{plain-md5}$password:$GroupID:$UserID::/home/$UserName/home/${UserName}::userdb_mail=maildir:~/mail/$fqdn/$local_part" >> /var/www/html/mail/domains/$fqdn/dovecot-passwd
	echo "$local_part:{plain-md5}$password:$GroupID:$UserID::/home/$UserName/home/${UserName}::userdb_mail=maildir:~/mail/$fqdn/$local_part"

done
			
