#!/bin/bash

for FullFileName in /var/www/html/webcp/nm/*.deletessl;
do
        if [ -f $FullFileName ]
        then
                Domain=$(basename "$FullFileName")
                Domain=${Domain%.*}
		echo "Domain: $Domain"
		DomainID=`cat $FullFileName`
		echo "DomainID: $DomainID"

		if [ -f "/etc/httpd/conf/ssl/$Domain.crt" ]
		then
			rm -fr /etc/httpd/conf/ssl/$Domain.crt
		fi

		if [ -f "/etc/httpd/conf/ssl/$Domain.csr" ]
		then
			rm -fr /etc/httpd/conf/ssl/$Domain.csr
		fi

		if [ -f "/etc/httpd/conf/ssl/$Domain.key" ]
		then
			rm -fr /etc/httpd/conf/ssl/$Domain.key
		fi
	
		if [ "$DomainID" != "-1" ]
		then
			touch /var/www/html/webcp/nm/$DomainID.subdomain
		fi

		rm -fr $FullFileName
        fi
done
