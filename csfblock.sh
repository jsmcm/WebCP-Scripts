#!/bin/bash

IP=$1
Ports=$2
Type=$3
Direction=$4
Timeout=$5
Message=$6
Logs=$7
Triggered=$8
Password=`cat /usr/webcp/password`

if [ "$Triggered" == "LF_CUSTOMTRIGGER" ]
then
	if [[ $Message == *webcp* ]]
	then
		Triggered="WebCP"
	fi
fi

echo "INSERT INTO csf VALUES (0, '$IP', '', '', '', '$Ports', $Type, '$Direction', '$(date +\%Y-\%m-\%d\ \%H:\%M:\%S)', $Timeout, '$Message', '$Logs', '$Triggered');" >> /tmp/csfdeny

$(mysql cpadmin -u root -p${Password} -se "INSERT INTO csf VALUES (0, '$IP', '', '', '', '$Ports', $Type, '$Direction', '$(date +\%Y-\%m-\%d\ \%H:\%M:\%S)', $Timeout, '$Message', '$Logs', '$Triggered');")

                URL="http://localhost:10025/fail2ban/update_dns.php?ip=${IP}"
                /usr/bin/wget -O /dev/null -o /dev/null -q $URL

