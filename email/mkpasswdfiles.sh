#!/bin/bash

Password=`/usr/webcp/get_password.sh`

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

mysql cpadmin -u root -p${Password} -N -e "SELECT local_part, password FROM mailboxes WHERE domain_user_name='$UserName' AND active=1" | while read local_part password; do

echo "$local_part@$DomainName:$password" >> /var/www/html/mail/domains/$DomainName/passwd

echo "$local_part:{plain-md5}$password:$GroupID:$UserID::/home/$UserName::userdb_mail=maildir:~/mail/$DomainName/$local_part" >> /var/www/html/mail/domains/$DomainName/dovecot-passwd

done
			
