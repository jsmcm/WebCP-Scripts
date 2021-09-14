#!/bin/bash

x=$(pgrep bayes_learn.sh | wc -w)
if [ $x -gt 2 ]; then
        exit
fi


Password=`/usr/webcp/get_password.sh`
User=`/usr/webcp/get_username.sh`
DB_HOST=`/usr/webcp/get_db_host.sh`

mysql cpadmin -u ${User} -p${Password} -h ${DB_HOST} -N -e "SELECT domain_user_name, local_part, fqdn FROM mailboxes, domains WHERE domains.deleted = 0 AND mailboxes.active = 1 AND mailboxes.domain_id = domains.id;" | while read domain_user_name local_part fqdn; do

	spamPath="/home/$domain_user_name/home/$domain_user_name/mail/$fqdn/$local_part/.Spam/cur"
	hamPath="/home/$domain_user_name/home/$domain_user_name/mail/$fqdn/$local_part/cur"
	
	if [ -d "$spamPath" ]
	then
		echo "sa-learn --spam --showdots $spamPath"
		su -c "sa-learn --spam --showdots $spamPath" - $domain_user_name
		echo "sa-learn --ham --showdots $hamPath"
		su -c "sa-learn --ham --showdots $hamPath" - $domain_user_name
	fi

done
