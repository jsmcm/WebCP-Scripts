#!/bin/bash
# subdomains.sh

DomainID=$1
PrimaryDomainName=$2
UserName=$3
IP=$4
sslRedirect=$5
phpVersion=$6
pagespeed=$7
webp=$8
useCache=$9
publicPath=${10}
accessControlAllowOrigin=${11}
accessControlAllowMethods=${12}
accessControlAllowHeaders=${13}
accessControlExposeHeaders=${14}


Password=`/usr/webcp/get_password.sh`
User=`/usr/webcp/get_username.sh`
DB_HOST=`/usr/webcp/get_db_host.sh`


echo "In subdomain, SubDomainID = $DomainID"

for NextSubDomainID in $(mysql cpadmin -u ${User} -p${Password} -h ${DB_HOST} -se "SELECT id FROM domains WHERE ancestor_domain_id = $DomainID AND deleted = 0 AND domain_type = 'subdomain';")
do
	
	NextSubDomainName=$(mysql cpadmin -u ${User} -p${Password} -h ${DB_HOST} -se "SELECT fqdn FROM domains WHERE deleted = 0 AND id = $NextSubDomainID;")
	Path=$(mysql cpadmin -u ${User} -p${Password} -h ${DB_HOST} -se "SELECT path FROM domains WHERE deleted = 0 AND id = $NextSubDomainID;")
		
	if [ "${#Path}" -gt "4" ]
	then
	
		if [ ! -d "$Path" ]; then
			mkdir "$Path" -p
			echo "<html><body>$NextSubDomainName page... Add content here</body></html>" > $Path/index.html
			
			chown $UserName.$UserName $Path -R	
			
		fi
	

		echo "PrimaryDomainName: $PrimaryDomainName"
		echo "DomainName: $DomainName"
		echo "NextSubDomainName: $NextSubDomainName"

		UseSSL=0
                if [ -f "/etc/nginx/ssl/$NextSubDomainName.crt" ] && [ -f "/etc/nginx/ssl/$NextSubDomainName.csr" ] && [ -f "/var/www/html/webcp/nm/$NextSubDomainName.crtchain" ]
                then
                	UseSSL=1
                elif [ -f "/etc/letsencrypt/live/$NextSubDomainName/cert.pem" ] && [ -f "/etc/letsencrypt/renewal/$NextSubDomainName.conf" ]
                then
                        UseSSL=2
                fi



                 if [ $UseSSL != 0 ]
                 then


        		if [ $sslRedirect == "enforce" ]
                        then
                        	/usr/webcp/domains/port80SSLRedirect.sh $NextSubDomainName $UserName "naked" $phpVersion $Path $PrimaryDomainName "$pagespeed" "$webp" "$useCache" "$publicPath" "$accessControlAllowOrigin" "$accessControlAllowMethods" "$accessControlAllowHeaders" "$accessControlExposeHeaders"
                        else
                        	/usr/webcp/domains/port80.sh $NextSubDomainName $UserName "naked" $phpVersion $Path $PrimaryDomainName "$pagespeed" "$webp" "$useCache" "$publicPath" "$accessControlAllowOrigin" "$accessControlAllowMethods" "$accessControlAllowHeaders" "$accessControlExposeHeaders"
                        fi

			/usr/webcp/domains/port443.sh $NextSubDomainName $UserName "naked" $phpVersion $Path $PrimaryDomainName $sslRedirect "$pagespeed" "$webp" "$useCache" "$publicPath" "$accessControlAllowOrigin" "$accessControlAllowMethods" "$accessControlAllowHeaders" "$accessControlExposeHeaders"

              	else
                	/usr/webcp/domains/port80.sh $NextSubDomainName $UserName "naked" $phpVersion $Path $PrimaryDomainName "$pagespeed" "$webp" "$useCache" "$publicPath" "$accessControlAllowOrigin" "$accessControlAllowMethods" "$accessControlAllowHeaders" "$accessControlExposeHeaders"
               	fi

	fi
done

echo "LEaving subdomains"

