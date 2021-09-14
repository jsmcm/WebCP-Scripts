#!/usr/bin/env bash

x=$(pgrep permban.sh | wc -w)
if [ $x -gt 2 ]; then
        exit
fi


Password=`/usr/webcp/get_password.sh`

DB_HOST=`/usr/webcp/get_db_host.sh`
User=`/usr/webcp/get_username.sh`

for FullFileName in /var/www/html/webcp/nm/*.permban;
do
	##echo $FullFileName
        x=$FullFileName
        echo "x: '$x'"
        y=${x%.permban}
        echo "y: '$y'"
        ip=${y##*/}
        echo "ip: '$ip'"

	ip=${ip//_/\/}
        echo "ip: '$ip'"

	if [ "$ip" != "*" ]
	then
		/usr/sbin/ufw insert 1 deny from $ip
		$(mysql cpadmin -u ${User} -p${Password} -h ${DB_HOST} -se "INSERT INTO fail2ban VALUES (0, '$ip', '', '', '', '*', 0, 'inout', '$(date +\%Y-\%m-\%d\ \%H:\%M:\%S)', 0, 'perm', 'perm', 'perm');")
		rm -fr $FullFileName
	fi

done

