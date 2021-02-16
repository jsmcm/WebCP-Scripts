#!/bin/bash

x=$(pgrep delete_freessl.sh | wc -w)
if [ $x -gt 2 ]; then
        exit
fi

DomainIDs=()
for FullFileName in /var/www/html/webcp/nm/*.deletefreessl;
do
        if [ -f $FullFileName ]
        then
                Domain=$(basename "$FullFileName")
                Domain=${Domain%.*}
		echo "Domain: $Domain"
		DomainID=`cat $FullFileName`
		echo "DomainID: $DomainID"

	        rm -fr /etc/letsencrypt/live/mail.$Domain
	        rm -fr /etc/letsencrypt/live/$Domain*
	        rm -fr /etc/letsencrypt/archive/$Domain*
	        rm -fr /etc/letsencrypt/renewal/$Domain*.conf

		if [ -L "/etc/letsencrypt/live/mail.$Domain" ]
		then
			rm -fr /etc/letsencrypt/live/mail.$Domain
		fi

		if [ "$DomainID" != "-1" ]
		then
			DomainIDs+=($DomainID)
		fi

		rm -fr $FullFileName
        fi
done

for item in ${DomainIDs[*]}
do
    touch /var/www/html/webcp/nm/$item.subdomain
done

