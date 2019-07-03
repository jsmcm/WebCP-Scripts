#!/bin/bash



export DISPLAY=:0.0
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/root/bin
HOME=/root

source $HOME/.profile

x=$(pgrep freessl.sh | wc -w)
if [ $x -gt 2 ]; then
        exit
fi

if [ ! -d "/etc/nginx/ssl/letsencrypt" ]
then
	/usr/webcp/utils/install_letsencrypt.sh
fi

DomainIDs=()
for FullFileName in /var/www/html/webcp/nm/*.freessl;
do
	if [ -f "$FullFileName" ]
	then

	HostName=$(basename "$FullFileName")
	HostName=${HostName%.*}

	while read line
	do
		echo "Line: $line"

	     	if [ ! -z "$line" ]
	        then
	
	            	if [[ "$line" == *"EmailAddress"* ]]; then
				echo "In email address"
	                         EmailAddress=$line
	                         EmailAddress=${EmailAddress##*EmailAddress=}
				echo "Email Address = $EmailAddress"
	            	elif [[ "$line" == *"DomainUserName"* ]]; then
	                         DomainUserName=$line
	                         DomainUserName=${DomainUserName##*DomainUserName=}

	            	elif [[ "$line" == *"Type"* ]]; then
	                         Type=$line
	                         Type=${Type##*Type=}

	            	elif [[ "$line" == *"Path"* ]]; then
	                         Path=$line
	                         Path=${Path##*Path=}

	            	elif [[ "$line" == *"PrimaryDomainID"* ]]; then
				echo "In PrimaryDomainID"
	                         PrimaryDomainID=$line
	                         PrimaryDomainID=${PrimaryDomainID##*PrimaryDomainID=}
			
				echo "Adding $PrimaryDomainID to Domains list"
				DomainIDs+=($PrimaryDomainID)		
	            	
			elif [[ "$line" == *"DomainID"* ]]; then
	                         DomainID=$line
	                         DomainID=${DomainID##*DomainID=}


			fi
		fi
	
	done <$FullFileName
				  
	mail=`/usr/webcp/dns_query.sh mail.$HostName`

        www=`/usr/webcp/dns_query.sh www.$HostName`
        if [ "$www" == "0" ]
        then
            Type="subdomain"
        fi

	if [ -z "$EmailAddress" ] 
	then
		EmailAddress="noreply@example.com"
	fi

	rm -fr /etc/letsencrypt/live/$HostName*
	rm -fr /etc/letsencrypt/archive/$HostName*
	rm -fr /etc/letsencrypt/renewal/$HostName*.conf

	cd /usr/webcp/
	/usr/webcp/freessl.exp "$HostName" "$Path" "$Type" "$EmailAddress" "$mail"

	if [ ! -d "/etc/letsencrypt/live/mail.$HostName" ]
	then
		ln -s /etc/letsencrypt/live/$HostName /etc/letsencrypt/live/mail.$HostName
	fi

	rm -fr $FullFileName
	fi
done

echo "looping"
for item in ${DomainIDs[*]}
do
	echo "Touching $item.subdomain"
    touch /var/www/html/webcp/nm/$item.subdomain
done

/usr/webcp/email/make_dovecot_ssl.sh

chmod 755 /etc/letsencrypt/{archive,live} -R
chgrp Debian-exim /etc/letsencrypt/{archive,live} -R

service dovecot restart

