#!/bin/bash

# parkeddomains.sh

DomainID=$1
PrimaryDomainName=$2
UserName=$3
IP=$4
sslRedirect=$5
phpVersion=$6


Password=`/usr/webcp/get_password.sh`

echo "In parkeddomain, ParkedDomainID = $DomainID"

for NextParkedDomainID in $(mysql cpadmin -u root -p${Password} -se "SELECT id FROM domains WHERE ancestor_domain_id = $DomainID AND deleted = 0 AND domain_type = 'parked';")
do
	
	parkedDomainName=$(mysql cpadmin -u root -p${Password} -se "SELECT fqdn FROM domains WHERE deleted = 0 AND id = $NextParkedDomainID;")
	path=$(mysql cpadmin -u root -p${Password} -se "SELECT path FROM domains WHERE deleted = 0 AND id = $NextParkedDomainID;")
	parentDomainId=$(mysql cpadmin -u root -p${Password} -se "SELECT parent_domain_id FROM domains WHERE deleted = 0 AND id = $NextParkedDomainID;")
	parentDomainName=$(mysql cpadmin -u root -p${Password} -se "SELECT fqdn FROM domains WHERE deleted = 0 AND id = $parentDomainId;")
	sslRedirect=$(mysql cpadmin -u root -p${Password} -se "SELECT setting_value FROM domain_settings WHERE deleted = 0 AND setting_name = 'ssl_redirect' AND domain_id = $NextParkedDomainID;")
	parkedRedirect=$(mysql cpadmin -u root -p${Password} -se "SELECT setting_value FROM domain_settings WHERE deleted = 0 AND setting_name = 'parked_redirect' AND domain_id = $NextParkedDomainID;")

	if [ "${#path}" -gt "4" ]
	then
	
		echo "parkedDomainName: $parkedDomainName"
		echo "path: $path"
		echo "parentDomainId: $parentDomainId"
		echo "parentDomainName: $parentDomainName"
		echo "sslRedirect: $sslRedirect"

		UseSSL=0
                if [ -f "/etc/httpd/conf/ssl/$parkedDomainName.crt" ] && [ -f "/etc/httpd/conf/ssl/$parkedDomainName.csr" ] && [ -f "/var/www/html/webcp/nm/$parkedDomainName.crtchain" ]
                then
                	UseSSL=1
                elif [ -f "/etc/letsencrypt/live/$parkedDomainName/cert.pem" ] && [ -f "/etc/letsencrypt/renewal/$parkedDomainName.conf" ]
                then
                        UseSSL=2
                fi



                 if [ $UseSSL != 0 ]
                 then


        		if [ "$sslRedirect" == "enforce" ]
                        then
                        	if [ "$parkedRedirect" == "redirect" ]
				then
                        		/usr/webcp/domains/port80SSLParkedRedirect.sh $parkedDomainName $UserName "naked" $phpVersion $path $parentDomainName
				else
                        		/usr/webcp/domains/port80SSLRedirect.sh $parkedDomainName $UserName "naked" $phpVersion $path $parentDomainName
                        	fi
                        else
                        	if [ $parkedRedirect == "redirect" ]
				then
					/usr/webcp/domains/port80ParkedRedirect.sh $parkedDomainName $UserName "naked" $phpVersion $path $parentDomainName
				else
                        		/usr/webcp/domains/port80.sh $parkedDomainName $UserName "naked" $phpVersion $path $parentDomainName
                        	fi
			fi

                        if [ $UseSSL == 1 ]
                        then
                        	CertChain=`cat /var/www/html/webcp/nm/$DomainName.crtchain`
                                echo "CertChain = $CertChain"
                                rm -fr /var/www/html/webcp/nm/$DomainName.crtchain

                                echo "  SSLCertificateFile /etc/nginx/ssl/$DomainName.crt" >> /etc/nginx/vhosts/$DomainName.conf
                                echo "  SSLCertificateKeyFile /etc/nginx/ssl/$DomainName.key" >> /etc/nginx/vhosts/$DomainName.conf
                                echo "  SSLCACertificateFile /etc/nginx/ssl/$CertChain" >> /etc/nginx/vhosts/$DomainName.conf
                       	elif [ $UseSSL == 2 ]
                        then

                    	    	if [ "$parkedRedirect" == "redirect" ]
				then
	                        	/usr/webcp/domains/port443ParkedRedirect.sh $parkedDomainName $UserName "naked" $phpVersion $path $parentDomainName $sslRedirect
				else
	                        	/usr/webcp/domains/port443.sh $parkedDomainName $UserName "naked" $phpVersion $path $parentDomainName $sslRedirect
	                        fi

                        fi
              	else
                        if [ "$parkedRedirect" == "redirect" ]
			then
				/usr/webcp/domains/port80ParkedRedirect.sh $parkedDomainName $UserName "naked" $phpVersion $path $parentDomainName
			else
                        	/usr/webcp/domains/port80.sh $parkedDomainName $UserName "naked" $phpVersion $path $parentDomainName
                        fi
               	fi

	fi
done

echo "LEaving parkeddomains"

