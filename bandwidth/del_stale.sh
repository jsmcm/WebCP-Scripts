#!/bin/bash

ifStart=`date '+%d'`

if [ $ifStart == 01 ]
then

        TempFile="bandwidth_stale_"
        TempFile="$TempFile`date '+%Y%m%d'`"

        if [ -f "/var/www/html/webcp/tmp/$TempFile" ]
        then
                exit
        fi

        touch "/var/www/html/webcp/tmp/$TempFile"

	Password=`cat /usr/webcp/password`

	SQL="DELETE FROM bandwidth WHERE time < '$(date +"%Y-%m")-01 00:00:00';"
	RESULT=$(mysql cpadmin -u root -p${Password} -se "$SQL")
	echo "$SQL"
				
	SQL="DELETE FROM user_notices WHERE notice_type IN ('80_traffic', '95_traffic') AND date < '$(date +"%Y-%m")-01 00:00:00';"
	RESULT=$(mysql cpadmin -u root -p${Password} -se "$SQL")
	echo "$SQL"
fi

