#!/usr/bin/env bash

x=$(pgrep unban.sh | wc -w)
if [ $x -gt 2 ]; then
        exit
fi


for FullFileName in /var/www/html/webcp/nm/*.unban;
do
	##echo $FullFileName
        x=$FullFileName
        echo "x: '$x'"
        y=${x%.unban}
        echo "y: '$y'"
        ip=${y##*/}
        echo "ip: '$ip'"

	ip=${ip//_/\/}

	if [ "$ip" != "*" ]
	then
		service=`cat $FullFileName`
		echo "service: '$service'"
		
		fail2ban-client set $service unbanip $ip
		rm -fr $FullFileName
	fi

done

