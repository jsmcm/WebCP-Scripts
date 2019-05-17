#!/usr/bin/env bash

x=$(pgrep permunban.sh | wc -w)
if [ $x -gt 2 ]; then
        exit
fi

Password=`/usr/webcp/get_password.sh`


for FullFileName in /var/www/html/webcp/nm/*.permunban;
do
	##echo $FullFileName
        x=$FullFileName
        echo "x: '$x'"
        y=${x%.permunban}
        echo "y: '$y'"
        ip=${y##*/}
        echo "ip: '$ip'"

	ip=${ip//_/\/}

	if [ "$ip" != "*" ]
	then
		/usr/sbin/ufw delete deny from $ip

		$(mysql cpadmin -u root -p${Password} -se "DELETE FROM fail2ban WHERE triggered = 'perm' AND ip = '$ip';")
		
		rm -fr $FullFileName
	fi

done

