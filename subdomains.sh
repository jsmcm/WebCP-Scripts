#!/bin/bash

# subdomains.sh

DomainID=$1
DomainName=$2
UserName=$3
PrimaryDomainName=$4
IP=$5

Password=`cat /usr/webcp/password`

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
	
				echo "" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
				echo "" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
		                echo "<VirtualHost $IP:80>" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
	        	        echo "   DocumentRoot \"$Path\"" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
		
	                	echo "   ServerName $NextSubDomainBuffer" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
	
				ServerAlias="www.$NextSubDomainBuffer mail.$NextSubDomainBuffer ftp.$NextSubDomainBuffer"
		
				for NextParkedDomainName in $(mysql cpadmin -u root -p${Password} -se "SELECT fqdn FROM domains WHERE parent_domain_id = $NextSubDomainID AND deleted = 0 AND domain_type = 'parked';")
				do
					ServerAlias="$ServerAlias $NextParkedDomainName www.$NextParkedDomainName mail.$NextParkedDomainName ftp.$NextParkedDomainName"
				done
		                
				echo "   ServerAlias $ServerAlias" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
	
	
				
				echo  "" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
				echo  "" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
	
				echo  "	<IfModule mod_security2.c>" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
	        		
				for URI in $(mysql cpadmin -u root -p${Password} -se "SELECT DISTINCT(extra2) FROM server_settings WHERE deleted = 0 AND setting = 'modsec_whitelist' AND extra1 = '$NextSubDomainBuffer';")
				do
					echo "		<LocationMatch \"$URI\">" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
	
					
					for ModsecID in $(mysql cpadmin -u root -p${Password} -se "SELECT value FROM server_settings WHERE deleted = 0 AND setting = 'modsec_whitelist' AND extra1 = '$NextSubDomainBuffer' AND extra2 = '$URI';")
					do
						echo "			SecRuleRemoveById $ModsecID" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
					done
	
			        	echo "		</LocationMatch>" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
				done
				
				echo "	</IfModule>" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
	
	
				echo  "" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
				echo  "" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
	
		
		                echo "   suPHP_Engine on" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
		                echo "   suPHP_UserGroup $UserName $UserName" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
		                echo "   AddHandler x-httpd-php .php .php3 .php4 .php5" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
		                echo "   suPHP_AddHandler x-httpd-php"   >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
		
		                echo "   CustomLog \"/home/$UserName/http-access.log\" combined" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
		
		                echo "   <Directory \"$Path\">" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
		                echo "      Options All" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
		                echo "      AllowOverride All" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
		                echo "      Order allow,deny" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
	        	        echo "      Allow from all" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
		                echo "   </Directory>" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
		
		
	
	        		echo "	ScriptAlias /cgi-bin/ $Path/cgi-bin/" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
	        		echo "	<Directory \"$Path/cgi-bin\">" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
	                	echo "		AllowOverride None" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
	                	echo "		Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
	                	echo " 		Order allow,deny" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
	                	echo "		Allow from all" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
	       		 	echo "	</Directory>" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf	

		
		                echo "</VirtualHost>" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf










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
					echo "<VirtualHost $IP:443>" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
					echo "  SSLEngine On" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
					echo "  SSLProtocol -all +SSLv3 +TLSv1" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
					echo "  SSLHonorCipherOrder On" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
					echo "  SSLCipherSuite ALL:!aNULL:!ADH:!eNULL:!LOW:!EXP:RC4+RSA:+HIGH:+MEDIUM:!SSLv2:!EXPORT" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
					echo "" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf

					if [ $UseSSL == 1 ]
					then
						echo "  SSLCertificateFile /etc/httpd/conf/ssl/$NextParkedDomainName.crt" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
						echo "  SSLCertificateKeyFile /etc/httpd/conf/ssl/$NextParkedDomainName.key" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
						echo "  SSLCACertificateFile /etc/httpd/conf/ssl/$CertChain" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
					elif [ $UseSSL == 2 ]
					then
						echo "  SSLCertificateFile /etc/letsencrypt/live/$NextParkedDomainName/cert.pem" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
						echo "  SSLCertificateKeyFile /etc/letsencrypt/live/$NextParkedDomainName/privkey.pem" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
						echo "  SSLCACertificateFile /etc/letsencrypt/live/$NextParkedDomainName/fullchain.pem" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
					fi

					echo "   DocumentRoot \"$Path\"" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
					echo "   ServerName $NextParkedDomainName" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf

					ServerAlias="www.$NextParkedDomainName mail.$NextParkedDomainName ftp.$NextParkedDomainName"
					echo "   ServerAlias $ServerAlias" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf


					echo  "" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
					echo  "" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf

					echo  " <IfModule mod_security2.c>" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf

					for URI in $(mysql cpadmin -u root -p${Password} -se "SELECT DISTINCT(extra2) FROM server_settings WHERE deleted = 0 AND setting = 'modsec_whitelist' AND extra1 = '$NextParkedDomainName';")
					do
						echo "          <LocationMatch \"$URI\">" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf


						for ModsecID in $(mysql cpadmin -u root -p${Password} -se "SELECT value FROM server_settings WHERE deleted = 0 AND setting = 'modsec_whitelist' AND extra1 = '$NextParkedDomainName' AND extra2 = '$URI';")
						do
							echo "                  SecRuleRemoveById $ModsecID" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
						done
						echo "          </LocationMatch>" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
					done
					echo "  </IfModule>" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf


					echo  "" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
					echo  "" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf





					echo "   suPHP_Engine on" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
					echo "   suPHP_UserGroup $UserName $UserName" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
					echo "   AddHandler x-httpd-php .php .php3 .php4 .php5" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
					echo "   suPHP_AddHandler x-httpd-php"   >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf

					echo "   CustomLog \"/home/$UserName/http-access.log\" combined" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf

					echo "   <Directory \"$Path\">" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
					echo "      Options All" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
					echo "      AllowOverride All" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
					echo "      Order allow,deny" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
					echo "      Allow from all" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
					echo "   </Directory>" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf


					echo "  ScriptAlias /cgi-bin/ $Path" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
					echo "  <Directory \"$Path\">" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
					echo "          AllowOverride None" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
					echo "          Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
					echo "          Order allow,deny" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
					echo "          Allow from all" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
					echo "  </Directory>" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf


					echo "</VirtualHost>" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
					echo ""
				fi
				
			done













			echo "checking for SSL in subdomains:"
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
                                echo "<VirtualHost $IP:443>" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
                                echo "  SSLEngine On" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
                                echo "  SSLProtocol -all +SSLv3 +TLSv1" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
                                echo "  SSLHonorCipherOrder On" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
                                echo "  SSLCipherSuite ALL:!aNULL:!ADH:!eNULL:!LOW:!EXP:RC4+RSA:+HIGH:+MEDIUM:!SSLv2:!EXPORT" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
                                echo "" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf

                                if [ $UseSSL == 1 ]
                                then
                                        echo "  SSLCertificateFile /etc/httpd/conf/ssl/$NextSubDomainBuffer.crt" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
                                        echo "  SSLCertificateKeyFile /etc/httpd/conf/ssl/$NextSubDomainBuffer.key" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
                                        echo "  SSLCACertificateFile /etc/httpd/conf/ssl/$CertChain" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
                                elif [ $UseSSL == 2 ]
                                then
                                        echo "  SSLCertificateFile /etc/letsencrypt/live/$NextSubDomainBuffer/cert.pem" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
                                        echo "  SSLCertificateKeyFile /etc/letsencrypt/live/$NextSubDomainBuffer/privkey.pem" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
                                        echo "  SSLCACertificateFile /etc/letsencrypt/live/$NextSubDomainBuffer/fullchain.pem" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
                                fi

                                echo "   DocumentRoot \"$Path\"" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
                                echo "   ServerName $NextSubDomainBuffer" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf

                                ServerAlias="www.$NextSubDomainBuffer mail.$NextSubDomainBuffer ftp.$NextSubDomainBuffer"

                                echo "   ServerAlias $ServerAlias" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf



                                echo  "" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
                                echo  "" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf

                                echo  " <IfModule mod_security2.c>" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf

                                for URI in $(mysql cpadmin -u root -p${Password} -se "SELECT DISTINCT(extra2) FROM server_settings WHERE deleted = 0 AND setting = 'modsec_whitelist' AND extra1 = '$NextSubDomainBuffer';")
                                do
                                        echo "          <LocationMatch \"$URI\">" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf


                                        for ModsecID in $(mysql cpadmin -u root -p${Password} -se "SELECT value FROM server_settings WHERE deleted = 0 AND setting = 'modsec_whitelist' AND extra1 = '$NextSubDomainBuffer' AND extra2 = '$URI';")
                                        do
                                                echo "                  SecRuleRemoveById $ModsecID" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
                                        done
                                        echo "          </LocationMatch>" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
                                done

                                echo "  </IfModule>" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf


                                echo  "" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
                                echo  "" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf





                                echo "   suPHP_Engine on" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
                                echo "   suPHP_UserGroup $UserName $UserName" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
                                echo "   AddHandler x-httpd-php .php .php3 .php4 .php5" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
                                echo "   suPHP_AddHandler x-httpd-php"   >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf

                                echo "   CustomLog \"/home/$UserName/http-access.log\" combined" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf

                                echo "   <Directory \"$Path\">" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
                                echo "      Options All" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
                                echo "      AllowOverride All" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
                                echo "      Order allow,deny" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
                                echo "      Allow from all" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
                                echo "   </Directory>" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf


                                echo "  ScriptAlias /cgi-bin/ $Path" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
                                echo "  <Directory \"/$Path\">" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
                                echo "          AllowOverride None" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
                                echo "          Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
                                echo "          Order allow,deny" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
                                echo "          Allow from all" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
                                echo "  </Directory>" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf


                                echo "</VirtualHost>" >> /etc/httpd/conf/vhosts/$PrimaryDomainName.conf
                                echo ""
				echo "Done adding ssl in subdomains"
                        fi
















	
	#########		/usr/webcp/subdomains.sh $NextSubDomainID $NextSubDomainBuffer $UserName $PrimaryDomainName
			fi
		done
	



echo "LEaving subdomains"



