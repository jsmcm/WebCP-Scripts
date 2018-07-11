#!/bin/bash

# subdomains.sh

DomainID=$1
DomainName=$2
UserName=$3
PrimaryDomainName=$4
IP=$5

Password=`/usr/webcp/get_password.sh`

		echo "In subdomain, SubDomainID = $DomainID"

		for NextSubDomainID in $(mysql cpadmin -u root -p${Password} -se "SELECT id FROM domains WHERE ancestor_domain_id = $DomainID AND deleted = 0 AND domain_type = 'subdomain';")
		do
			
				NextSubDomainBuffer=$(mysql cpadmin -u root -p${Password} -se "SELECT fqdn FROM domains WHERE deleted = 0 AND id = $NextSubDomainID;")
				Path=$(mysql cpadmin -u root -p${Password} -se "SELECT path FROM domains WHERE deleted = 0 AND id = $NextSubDomainID;")
		
			if [ "${#Path}" -gt "4" ]
			then
	
				if [ ! -d "$Path" ]; then
					mkdir "$Path" -p
	
					echo "<html><body>$NextSubDomainBuffer page... Add content here</body></html>" > $Path/index.html
			
					chown $UserName.$UserName $Path -R	
					
				fi
	

			echo "server {" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "        listen 80;" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "        listen [::]:80;" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "" >> /etc/nginx/sites-enabled/$DomainName.conf

			ServerAlias="www.$NextSubDomainBuffer mail.$NextSubDomainBuffer ftp.$NextSubDomainBuffer"

			for NextParkedDomainName in $(mysql cpadmin -u root -p${Password} -se "SELECT fqdn FROM domains WHERE parent_domain_id = $NextSubDomainID AND deleted = 0 AND domain_type = 'parked';")
			do
				ServerAlias="$ServerAlias $NextParkedDomainName www.$NextParkedDomainName mail.$NextParkedDomainName ftp.$NextParkedDomainName"
			done

			
			echo "        server_name $NextSubDomainBuffer $ServerAlias;" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "        root $Path;" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "	index index.php index.html index.htm;" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "        location / {" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "                try_files $uri $uri/ /index.php?$args;" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "        }" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "        location ~ \.php$ {" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "                include snippets/fastcgi-php.conf;" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "                fastcgi_pass unix:/run/php/php7.0-fpm-$UserName.sock;" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "                fastcgi_send_timeout 300;" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "                fastcgi_read_timeout 300;" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "        }" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "        location ~ /\.ht {" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "                deny all;" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "        }" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "}" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
			



                        for NextParkedDomainName in $(mysql cpadmin -u root -p${Password} -se "SELECT fqdn FROM domains WHERE parent_domain_id = $NextSubDomainID AND deleted = 0 AND domain_type = 'parked';")
                        do
					
				UseSSL=0
				if [ -f "/etc/httpd/conf/ssl/$NextParkedDomainName.crt" ] && [ -f "/etc/httpd/conf/ssl/$NextParkedDomainName.csr" ] && [ -f "/var/www/html/webcp/nm/$NextParkedDomainName.crtchain" ]
				then
					UseSSL=1
				elif [ -f "/etc/letsencrypt/live/$NextParkedDomainName/cert.pem" ] && [ -f "/etc/letsencrypt/renewal/$NextParkedDomainName.conf" ]
				then
					UseSSL=2
				fi

				if [ $UseSSL != 0 ]
				then
					CertChain=`cat /var/www/html/webcp/nm/$NextParkedDomainName.crtchain`
					echo "CertChain = $CertChain"
					rm -fr /var/www/html/webcp/nm/$NextParkedDomainName.crtchain

					echo "They're HERE!"
				fi
				
			done



			echo "PrimaryDomainName: $PrimaryDomainName"
			echo "DomainName: $DomainName"
			echo "NextSubDomainBuffer: $NextSubDomainBuffer"


                        UseSSL=0
                        if [ -f "/etc/httpd/conf/ssl/$NextSubDomainBuffer.crt" ] && [ -f "/etc/httpd/conf/ssl/$NextSubDomainBuffer.csr" ] && [ -f "/var/www/html/webcp/nm/$NextSubDomainBuffer.crtchain" ]
                        then
                                UseSSL=1
                        elif [ -f "/etc/letsencrypt/live/$NextSubDomainBuffer/cert.pem" ] && [ -f "/etc/letsencrypt/renewal/$NextSubDomainBuffer.conf" ]
                        then
                                UseSSL=2
                        fi


                        if [ $UseSSL != 0 ]
                        then
				echo ""
				echo "In subdomains adding ssl for $NextSubDomainBuffer"

                                CertChain=`cat /var/www/html/webcp/nm/$PrimaryDomainName.crtchain`
                                echo "CertChain = $CertChain"
                                rm -fr /var/www/html/webcp/nm/$PrimaryDomainName.crtchain

                                echo "They're HERE IN SUBDOMAINS"
                                echo "<VirtualHost $IP:443>" >> /etc/nginx/sites-enabled/$PrimaryDomainName.conf
                                echo "  SSLEngine On" >> /etc/nginx/sites-enabled/$PrimaryDomainName.conf
                                echo "  SSLProtocol -all +SSLv3 +TLSv1" >> /etc/nginx/sites-enabled/$PrimaryDomainName.conf
                                echo "  SSLHonorCipherOrder On" >> /etc/nginx/sites-enabled/$PrimaryDomainName.conf
                                echo "  SSLCipherSuite ALL:!aNULL:!ADH:!eNULL:!LOW:!EXP:RC4+RSA:+HIGH:+MEDIUM:!SSLv2:!EXPORT" >> /etc/nginx/sites-enabled/$PrimaryDomainName.conf
                                echo "" >> /etc/nginx/sites-enabled/$PrimaryDomainName.conf

                                if [ $UseSSL == 1 ]
                                then
                                        echo "  SSLCertificateFile /etc/httpd/conf/ssl/$NextSubDomainBuffer.crt" >> /etc/nginx/sites-enabled/$PrimaryDomainName.conf
                                        echo "  SSLCertificateKeyFile /etc/httpd/conf/ssl/$NextSubDomainBuffer.key" >> /etc/nginx/sites-enabled/$PrimaryDomainName.conf
                                        echo "  SSLCACertificateFile /etc/httpd/conf/ssl/$CertChain" >> /etc/nginx/sites-enabled/$PrimaryDomainName.conf
                                elif [ $UseSSL == 2 ]
                                then
                                        echo "  SSLCertificateFile /etc/letsencrypt/live/$NextSubDomainBuffer/cert.pem" >> /etc/nginx/sites-enabled/$PrimaryDomainName.conf
                                        echo "  SSLCertificateKeyFile /etc/letsencrypt/live/$NextSubDomainBuffer/privkey.pem" >> /etc/nginx/sites-enabled/$PrimaryDomainName.conf
                                        echo "  SSLCACertificateFile /etc/letsencrypt/live/$NextSubDomainBuffer/fullchain.pem" >> /etc/nginx/sites-enabled/$PrimaryDomainName.conf
                                fi

                                echo "   DocumentRoot \"$Path\"" >> /etc/nginx/sites-enabled/$PrimaryDomainName.conf
                                echo "   ServerName $NextSubDomainBuffer" >> /etc/nginx/sites-enabled/$PrimaryDomainName.conf

                                ServerAlias="www.$NextSubDomainBuffer mail.$NextSubDomainBuffer ftp.$NextSubDomainBuffer"

                                echo "   ServerAlias $ServerAlias" >> /etc/nginx/sites-enabled/$PrimaryDomainName.conf

                                echo  "" >> /etc/nginx/sites-enabled/$PrimaryDomainName.conf
                                echo  "" >> /etc/nginx/sites-enabled/$PrimaryDomainName.conf

                                echo "</VirtualHost>" >> /etc/nginx/sites-enabled/$PrimaryDomainName.conf
                                echo ""
				echo "Done adding ssl in subdomains"
                        fi

	
			fi
		done
	



echo "LEaving subdomains"



