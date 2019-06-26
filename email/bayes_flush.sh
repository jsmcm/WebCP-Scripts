#!/bin/bash

x=$(pgrep bayes_flush.sh | wc -w)
if [ $x -gt 2 ]; then
        exit
fi


Password=`/usr/webcp/get_password.sh`

mysql cpadmin -u root -p${Password} -N -e "SELECT domain_user_name FROM mailboxes, domains WHERE domains.deleted = 0 AND mailboxes.active = 1 AND mailboxes.domain_id = domains.id;" | while read domain_user_name; do

	su -c "sa-learn --force-expire" - $domain_user_name

done
