#!/usr/bin/env bash

x=$(pgrep ban.sh | wc -w)
if [ $x -gt 2 ]; then
        exit
fi


for FullFileName in /var/www/html/webcp/nm/*.ban;
do
	##echo $FullFileName
        x=$FullFileName
        echo "x: '$x'"
        y=${x%.ban}
        echo "y: '$y'"
        ip=${y##*/}
        echo "ip: '$ip'"

	ip=${ip//_/\/}

	if [ "$ip" != "*" ]
	then
		fail2ban-client set webcp-manual banip $ip
		rm -fr $FullFileName
	fi

done

