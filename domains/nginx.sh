#!/bin/bash

DomainID=$1 
DomainName=$2
UserName=$3
IP=$4
redirect=$5
sslRedirect=$6
phpVersion=$7


echo "in Nginx DomainID: $DomainID"
echo "in Nginx DomainName: $DomainName"
echo "in Nginx UserName: $UserName"
echo "in Nginx IP: $IP"
echo "in Nginx redirect: $redirect"
echo "in Nginx sslRedirect: $sslRedirect"
echo "in Nginx phpVersion: $phpVersion"

Password=`/usr/webcp/get_password.sh`


			echo "" > /etc/nginx/sites-enabled/$DomainName.conf


			echo "Checking for crt and crs files for $DomainName"
			
			UseSSL=0	
			if [ -f "/etc/nginx/ssl/$DomainName.crt" ] && [ -f "/etc/nginx/ssl/$DomainName.csr" ] && [ -f "/var/www/html/webcp/nm/$DomainName.crtchain" ]
			then
				UseSSL=1
			elif [ -f "/etc/letsencrypt/live/$DomainName/cert.pem" ] && [ -f "/etc/letsencrypt/renewal/$DomainName.conf" ] 
			then
				UseSSL=2
			fi

	
			if [ $UseSSL != 0 ]
			then


				if [ "$sslRedirect" == "enforce" ]
				then
					/usr/webcp/domains/port80SSLRedirect.sh "$DomainName" "$UserName" "$redirect" "$phpVersion" "" ""
				else
					/usr/webcp/domains/port80.sh "$DomainName" "$UserName" "$redirect" "$phpVersion" "" ""
				fi


				if [ $UseSSL == 1 ]
				then
					CertChain=`cat /var/www/html/webcp/nm/$DomainName.crtchain`
					echo "CertChain = $CertChain"
					rm -fr /var/www/html/webcp/nm/$DomainName.crtchain
					
					echo "	SSLCertificateFile /etc/nginx/ssl/$DomainName.crt" >> /etc/nginx/vhosts/$DomainName.conf
		                	echo "	SSLCertificateKeyFile /etc/nginx/ssl/$DomainName.key" >> /etc/nginx/vhosts/$DomainName.conf
		                	echo "	SSLCACertificateFile /etc/nginx/ssl/$CertChain" >> /etc/nginx/vhosts/$DomainName.conf
				elif [ $UseSSL == 2 ]
				then

					/usr/webcp/domains/port443.sh "$DomainName" "$UserName" "$redirect" "$phpVersion" "" ""

				fi
			else
				/usr/webcp/domains/port80.sh "$DomainName" "$UserName" "$redirect" "$phpVersion" "" ""
			fi



			/usr/webcp/domains/services.sh "$DomainName" "$UserName" "$phpVersion"

