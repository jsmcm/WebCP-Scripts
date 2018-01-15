#!/bin/bash

x=$(pgrep domains.sh | wc -w)
if [ $x -gt 2 ]; then
        exit
fi

SkipRestartCheck=$1
Password=`cat /usr/webcp/password`

Restart=0

SharedIP=""

for FullFileName in /var/www/html/webcp/nm/*.subdomain; 
do

	if [ -f $FullFileName ]
	then	
		if [ "$SharedIP" == "" ]
		then
			SharedIP=$(mysql cpadmin -u root -p${Password} -se "SELECT IFNULL(MIN(option_value), '*') FROM dns_options WHERE option_name = 'ip' AND deleted = 0 AND extra1 = 'shared' LIMIT 1;")
			echo "SharedIP: $SharedIP"
		fi

		##echo $FullFileName
		x=$FullFileName
                echo "x: '$x'"
		y=${x%.subdomain}
                echo "y: '$y'"
		DomainID=${y##*/}
                echo "file: '$DomainID'"

		DomainName=$(mysql cpadmin -u root -p${Password} -se "SELECT fqdn FROM domains WHERE deleted = 0 AND id = $DomainID;")
		UserName=$(mysql cpadmin -u root -p${Password} -se "SELECT UserName FROM domains WHERE deleted = 0 AND id = $DomainID;")
		GroupID=$(mysql cpadmin -u root -p${Password} -se "SELECT Gid FROM domains WHERE deleted = 0 AND id = $DomainID;")
		UserID=$(mysql cpadmin -u root -p${Password} -se "SELECT Uid FROM domains WHERE deleted = 0 AND id = $DomainID;")
		UserQuota=$(mysql cpadmin -u root -p${Password} -se "SELECT (value / 1024) FROM domains, package_options WHERE domains.deleted = 0 AND package_options.deleted = 0 AND package_options.package_id = domains.package_id AND package_options.setting = 'DiskSpace' AND domains.UserName = '$UserName' AND domains.domain_type = 'primary';")
		IP=$(mysql cpadmin -u root -p${Password} -se "SELECT option_value FROM dns_options WHERE option_name = 'ip' AND extra1 = '$DomainName' AND deleted = 0 UNION  SELECT IFNULL(MIN(option_value), '*') FROM dns_options WHERE option_name = 'ip' AND deleted = 0 AND extra1 = 'shared' AND NOT EXISTS (SELECT option_value FROM dns_options WHERE option_name = 'ip' AND extra1 = '$DomainName' AND deleted = 0) LIMIT 1;")

		#echo "UserName: $UserName" > /usr/webcp/domains.txt
		#echo "DomainName: $DomainName" >>  /usr/webcp/domains.txt
		#echo "GroupID: $GroupID" >> /usr/webcp/domains.txt
		#echo "UserID: $UserID" >> /usr/webcp/domains.txt

		mkdir /etc/awstats

		cat /usr/webcp/templates/awstats.sample.conf | \
		sed -e "s/\\\$DOMAIN/$DomainName/g" | \
		sed -e "s/\\\$USERNAME/$UserName/g" | \
		sed -e "s/\\\$ALIASES/$ALIASES/g" > \
		"/etc/awstats/awstats.$DomainName.conf"


		if [ "${#UserName}" -gt "4" ]
		then
		
			#echo "groupadd $UserName -g $GroupID" >> /usr/webcp/domains.txt
		        groupadd $UserName -g $GroupID
	
			# To add a password please see /usr/webcp/backups/mkdirs.sh
			#echo "adduser $UserName -g $UserName -u $UserID" >> /usr/webcp/domains.txt
	                adduser $UserName -g $UserName -u $UserID

	                chmod 755 /home/$UserName
	                chown $UserName.$UserName /home/$UserName
	
	                chown $UserName.$UserName /home/$UserName/public_html
	                chmod 755 /home/$UserName/public_html
	
			echo "Setting $UserName to ${UserQuota%.*}" >> /home/q.txt
			setquota -u $UserName ${UserQuota%.*} ${UserQuota%.*} 0 0 -a ext4
	
	                chmod 755 /home/$UserName/.passwd -R
	                chmod 770 /home/$UserName/.passwd


	                chown apache.apache /home/$UserName/.passwd -R
	                chown $UserName.$UserName /home/$UserName/.passwd/read.php
	                chown $UserName.$UserName /home/$UserName/.passwd/write.php
	                chown $UserName.apache /home/$UserName/.passwd

	
	                chmod 755 /home/$UserName/public_html/index.html
	                chown $UserName.$UserName /home/$UserName/public_html/index.html
	
			#echo "making domain /home/$UserName/mail" >> /usr/webcp/domains.txt
	                mkdir /home/$UserName/mail
			
			#echo "chmod 755 /home/$UserName/mail" >> /usr/webcp/domains.txt
	                chmod 755 /home/$UserName/mail
	
			#echo "chown $UserName.$UserName /home/$UserName/mail" >> /usr/webcp/domains.txt
	                chown $UserName.$UserName /home/$UserName/mail
	
	                mkdir /home/$UserName/mail/$DomainName
			#echo "making domain /home/$UserName/mail/$DomainName" >> /usr/webcp/domains.txt
        	        
			chmod 755 /home/$UserName/mail/$DomainName
			#echo "chmoding 755 /home/$UserName/mail/$DomainName" >> /usr/webcp/domains.txt
			
			#echo "chowing $UserName.$UserName /home/$UserName/mail/$Domain" >> /usr/webcp/domains.txt
	                chown $UserName.$UserName /home/$UserName/mail/$DomainName
	
			if [ -f "/etc/httpd/conf/vhosts/$DomainName.conf" ]
			then
				rm -fr /etc/httpd/conf/vhosts/$DomainName.conf
			fi

			echo "Checking for crt and crs files for $DomainName"
			
			UseSSL=0	
			if [ -f "/etc/httpd/conf/ssl/$DomainName.crt" ] && [ -f "/etc/httpd/conf/ssl/$DomainName.csr" ] && [ -f "/var/www/html/webcp/nm/$DomainName.crtchain" ]
			then
				UseSSL=1
			elif [ -f "/etc/letsencrypt/live/$DomainName/cert.pem" ] && [ -f "/etc/letsencrypt/renewal/$DomainName.conf" ] 
			then
				UseSSL=2
			fi

	
			if [ $UseSSL != 0 ]
			then
				CertChain=`cat /var/www/html/webcp/nm/$DomainName.crtchain`
				echo "CertChain = $CertChain"
				rm -fr /var/www/html/webcp/nm/$DomainName.crtchain

				echo "They're HERE!"
	                	echo "<VirtualHost $IP:443>" > /etc/httpd/conf/vhosts/$DomainName.conf
	                	echo "	SSLEngine On" >> /etc/httpd/conf/vhosts/$DomainName.conf
	                	echo "	SSLProtocol -all +SSLv3 +TLSv1" >> /etc/httpd/conf/vhosts/$DomainName.conf
	                	echo "	SSLHonorCipherOrder On" >> /etc/httpd/conf/vhosts/$DomainName.conf
	                	echo "	SSLCipherSuite ALL:!aNULL:!ADH:!eNULL:!LOW:!EXP:RC4+RSA:+HIGH:+MEDIUM:!SSLv2:!EXPORT" >> /etc/httpd/conf/vhosts/$DomainName.conf
	                	echo "" >> /etc/httpd/conf/vhosts/$DomainName.conf
	                
				if [ $UseSSL == 1 ]
				then
					echo "	SSLCertificateFile /etc/httpd/conf/ssl/$DomainName.crt" >> /etc/httpd/conf/vhosts/$DomainName.conf
		                	echo "	SSLCertificateKeyFile /etc/httpd/conf/ssl/$DomainName.key" >> /etc/httpd/conf/vhosts/$DomainName.conf
		                	echo "	SSLCACertificateFile /etc/httpd/conf/ssl/$CertChain" >> /etc/httpd/conf/vhosts/$DomainName.conf
				elif [ $UseSSL == 2 ]
				then
				        echo "  SSLCertificateFile /etc/letsencrypt/live/$DomainName/cert.pem" >> /etc/httpd/conf/vhosts/$DomainName.conf
				        echo "  SSLCertificateKeyFile /etc/letsencrypt/live/$DomainName/privkey.pem" >> /etc/httpd/conf/vhosts/$DomainName.conf
				        echo "  SSLCACertificateFile /etc/letsencrypt/live/$DomainName/fullchain.pem" >> /etc/httpd/conf/vhosts/$DomainName.conf
				fi

	               	 	echo "   DocumentRoot \"/home/$UserName/public_html\"" >> /etc/httpd/conf/vhosts/$DomainName.conf
	               	 	echo "   ServerName $DomainName" >> /etc/httpd/conf/vhosts/$DomainName.conf
	
				ServerAlias="www.$DomainName mail.$DomainName ftp.$DomainName"
				echo "   ServerAlias $ServerAlias" >> /etc/httpd/conf/vhosts/$DomainName.conf
	
	
	                	echo  "" >> /etc/httpd/conf/vhosts/$DomainName.conf
	                	echo  "" >> /etc/httpd/conf/vhosts/$DomainName.conf
	
	               		echo  " <IfModule mod_security2.c>" >> /etc/httpd/conf/vhosts/$DomainName.conf
	
	                    	for URI in $(mysql cpadmin -u root -p${Password} -se "SELECT DISTINCT(extra2) FROM server_settings WHERE deleted = 0 AND setting = 'modsec_whitelist' AND extra1 = '$DomainName';")
	                    	do
	                        	echo "          <LocationMatch \"$URI\">" >> /etc/httpd/conf/vhosts/$DomainName.conf
	
	
	                            	for ModsecID in $(mysql cpadmin -u root -p${Password} -se "SELECT value FROM server_settings WHERE deleted = 0 AND setting = 'modsec_whitelist' AND extra1 = '$DomainName' AND extra2 = '$URI';")
	                            	do
	                                    	echo "                  SecRuleRemoveById $ModsecID" >> /etc/httpd/conf/vhosts/$DomainName.conf
	                            	done
	                            	echo "          </LocationMatch>" >> /etc/httpd/conf/vhosts/$DomainName.conf
	                    	done
	
	                    	echo "  </IfModule>" >> /etc/httpd/conf/vhosts/$DomainName.conf
	
	
	                   	echo  "" >> /etc/httpd/conf/vhosts/$DomainName.conf
	                    	echo  "" >> /etc/httpd/conf/vhosts/$DomainName.conf
	
		
		
			
	
	        	        echo "   suPHP_Engine on" >> /etc/httpd/conf/vhosts/$DomainName.conf
		                echo "   suPHP_UserGroup $UserName $UserName" >> /etc/httpd/conf/vhosts/$DomainName.conf
		                echo "   AddHandler x-httpd-php .php .php3 .php4 .php5" >> /etc/httpd/conf/vhosts/$DomainName.conf
		                echo "   suPHP_AddHandler x-httpd-php"   >> /etc/httpd/conf/vhosts/$DomainName.conf
			
		                echo "   CustomLog \"/home/$UserName/http-access.log\" combined" >> /etc/httpd/conf/vhosts/$DomainName.conf
		
		                echo "   <Directory \"/home/$UserName/public_html\">" >> /etc/httpd/conf/vhosts/$DomainName.conf
		                echo "      Options All" >> /etc/httpd/conf/vhosts/$DomainName.conf
		                echo "      AllowOverride All" >> /etc/httpd/conf/vhosts/$DomainName.conf
		                echo "      Order allow,deny" >> /etc/httpd/conf/vhosts/$DomainName.conf
		                echo "      Allow from all" >> /etc/httpd/conf/vhosts/$DomainName.conf
		                echo "   </Directory>" >> /etc/httpd/conf/vhosts/$DomainName.conf
		
		
		                echo "  ScriptAlias /cgi-bin/ /home/$UserName/public_html/cgi-bin/" >> /etc/httpd/conf/vhosts/$DomainName.conf
		                echo "  <Directory \"/home/$UserName/public_html/cgi-bin\">" >> /etc/httpd/conf/vhosts/$DomainName.conf
		                echo "          AllowOverride None" >> /etc/httpd/conf/vhosts/$DomainName.conf
		                echo "          Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch" >> /etc/httpd/conf/vhosts/$DomainName.conf
		                echo "          Order allow,deny" >> /etc/httpd/conf/vhosts/$DomainName.conf
		                echo "          Allow from all" >> /etc/httpd/conf/vhosts/$DomainName.conf
		                echo "  </Directory>" >> /etc/httpd/conf/vhosts/$DomainName.conf
		

	        	        echo "</VirtualHost>" >> /etc/httpd/conf/vhosts/$DomainName.conf
				echo ""
			fi	
	
	        
		        echo "<VirtualHost $IP:80>" >> /etc/httpd/conf/vhosts/$DomainName.conf
	                echo "   DocumentRoot \"/home/$UserName/public_html\"" >> /etc/httpd/conf/vhosts/$DomainName.conf
	
	                echo "   ServerName $DomainName" >> /etc/httpd/conf/vhosts/$DomainName.conf
	
			ServerAlias="www.$DomainName mail.$DomainName ftp.$DomainName"
	
			for NextParkedDomainName in $(mysql cpadmin -u root -p${Password} -se "SELECT fqdn FROM domains WHERE parent_domain_id = $DomainID AND deleted = 0 AND domain_type = 'parked';")
			do
				ServerAlias="$ServerAlias $NextParkedDomainName www.$NextParkedDomainName mail.$NextParkedDomainName ftp.$NextParkedDomainName"
	                
				# while we're looping through parked domains, create their mail directories
				mkdir /home/$UserName/mail/$NextParkedDomainName
				#echo "making domain /home/$UserName/mail/$NextParkedDomainName" >> /usr/webcp/domains.txt
	                
				chmod 755 /home/$UserName/mail/$NextParkedDomainName
				#echo "chmoding 755 /home/$UserName/mail/$NextParkedDomainName" >> /usr/webcp/domains.txt
			
				#echo "chowing $UserName.$UserName /home/$UserName/mail/$NextParkedDomain" >> /usr/webcp/domains.txt
		                chown $UserName.$UserName /home/$UserName/mail/$NextParkedDomainName
			done
	                
			echo "   ServerAlias $ServerAlias" >> /etc/httpd/conf/vhosts/$DomainName.conf
	
	
	                echo  "" >> /etc/httpd/conf/vhosts/$DomainName.conf
	                echo  "" >> /etc/httpd/conf/vhosts/$DomainName.conf
	
	                echo  " <IfModule mod_security2.c>" >> /etc/httpd/conf/vhosts/$DomainName.conf
	
	                    for URI in $(mysql cpadmin -u root -p${Password} -se "SELECT DISTINCT(extra2) FROM server_settings WHERE deleted = 0 AND setting = 'modsec_whitelist' AND extra1 = '$DomainName';")
	                    do
	                            echo "          <LocationMatch \"$URI\">" >> /etc/httpd/conf/vhosts/$DomainName.conf
	
	
	                            for ModsecID in $(mysql cpadmin -u root -p${Password} -se "SELECT value FROM server_settings WHERE deleted = 0 AND setting = 'modsec_whitelist' AND extra1 = '$DomainName' AND extra2 = '$URI';")
	                            do
	                                    echo "                  SecRuleRemoveById $ModsecID" >> /etc/httpd/conf/vhosts/$DomainName.conf
	                            done
	                            echo "          </LocationMatch>" >> /etc/httpd/conf/vhosts/$DomainName.conf
	                    done
	
	                    echo "  </IfModule>" >> /etc/httpd/conf/vhosts/$DomainName.conf
	
	
	                    echo  "" >> /etc/httpd/conf/vhosts/$DomainName.conf
	                    echo  "" >> /etc/httpd/conf/vhosts/$DomainName.conf
	
	
	
	

        	        echo "   suPHP_Engine on" >> /etc/httpd/conf/vhosts/$DomainName.conf
	                echo "   suPHP_UserGroup $UserName $UserName" >> /etc/httpd/conf/vhosts/$DomainName.conf
	                echo "   AddHandler x-httpd-php .php .php3 .php4 .php5" >> /etc/httpd/conf/vhosts/$DomainName.conf
	                echo "   suPHP_AddHandler x-httpd-php"   >> /etc/httpd/conf/vhosts/$DomainName.conf
	
	                echo "   CustomLog \"/home/$UserName/http-access.log\" combined" >> /etc/httpd/conf/vhosts/$DomainName.conf
	
	                echo "   <Directory \"/home/$UserName/public_html\">" >> /etc/httpd/conf/vhosts/$DomainName.conf
	                echo "      Options All" >> /etc/httpd/conf/vhosts/$DomainName.conf
	                echo "      AllowOverride All" >> /etc/httpd/conf/vhosts/$DomainName.conf
	                echo "      Order allow,deny" >> /etc/httpd/conf/vhosts/$DomainName.conf
	                echo "      Allow from all" >> /etc/httpd/conf/vhosts/$DomainName.conf
	                echo "   </Directory>" >> /etc/httpd/conf/vhosts/$DomainName.conf
	
	
	                echo "  ScriptAlias /cgi-bin/ /home/$UserName/public_html/cgi-bin/" >> /etc/httpd/conf/vhosts/$DomainName.conf
	                echo "  <Directory \"/home/$UserName/public_html/cgi-bin\">" >> /etc/httpd/conf/vhosts/$DomainName.conf
	                echo "          AllowOverride None" >> /etc/httpd/conf/vhosts/$DomainName.conf
	                echo "          Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch" >> /etc/httpd/conf/vhosts/$DomainName.conf
	                echo "          Order allow,deny" >> /etc/httpd/conf/vhosts/$DomainName.conf
	                echo "          Allow from all" >> /etc/httpd/conf/vhosts/$DomainName.conf
	                echo "  </Directory>" >> /etc/httpd/conf/vhosts/$DomainName.conf
	



        	        echo "</VirtualHost>" >> /etc/httpd/conf/vhosts/$DomainName.conf
	
	
	                echo "<VirtualHost $IP:20001>" >> /etc/httpd/conf/vhosts/$DomainName.conf
	                echo "   DocumentRoot \"/home/$UserName/.passwd\"" >> /etc/httpd/conf/vhosts/$DomainName.conf
	
	                echo "   ServerName $DomainName" >> /etc/httpd/conf/vhosts/$DomainName.conf
	
	                echo "   suPHP_Engine on" >> /etc/httpd/conf/vhosts/$DomainName.conf
	                echo "   suPHP_UserGroup $UserName $UserName" >> /etc/httpd/conf/vhosts/$DomainName.conf
	                echo "   AddHandler x-httpd-php .php .php3 .php4 .php5" >> /etc/httpd/conf/vhosts/$DomainName.conf
	                echo "   suPHP_AddHandler x-httpd-php"   >> /etc/httpd/conf/vhosts/$DomainName.conf
	
	                echo "   CustomLog \"/home/$UserName/http-access.log\" combined" >> /etc/httpd/conf/vhosts/$DomainName.conf
		
	                echo "</VirtualHost>" >> /etc/httpd/conf/vhosts/$DomainName.conf
	
	
	                echo "<VirtualHost $IP:20010>" >> /etc/httpd/conf/vhosts/$DomainName.conf
	                echo "   DocumentRoot \"/home/$UserName/.editor\"" >> /etc/httpd/conf/vhosts/$DomainName.conf
	
	                echo "   ServerName $DomainName" >> /etc/httpd/conf/vhosts/$DomainName.conf
	
        	        echo "   suPHP_Engine on" >> /etc/httpd/conf/vhosts/$DomainName.conf
	                echo "   suPHP_UserGroup $UserName $UserName" >> /etc/httpd/conf/vhosts/$DomainName.conf
	                echo "   AddHandler x-httpd-php .php .php3 .php4 .php5" >> /etc/httpd/conf/vhosts/$DomainName.conf
        	        echo "   suPHP_AddHandler x-httpd-php"   >> /etc/httpd/conf/vhosts/$DomainName.conf

	                echo "   CustomLog \"/home/$UserName/http-access.log\" combined" >> /etc/httpd/conf/vhosts/$DomainName.conf
	
	                echo "</VirtualHost>" >> /etc/httpd/conf/vhosts/$DomainName.conf
	                
			echo "<VirtualHost $IP:20020>" >> /etc/httpd/conf/vhosts/$DomainName.conf
        	        echo "   DocumentRoot \"/home/$UserName/.cron\"" >> /etc/httpd/conf/vhosts/$DomainName.conf

	                echo "   ServerName $DomainName" >> /etc/httpd/conf/vhosts/$DomainName.conf
	
	                echo "   suPHP_Engine on" >> /etc/httpd/conf/vhosts/$DomainName.conf
	                echo "   suPHP_UserGroup $UserName $UserName" >> /etc/httpd/conf/vhosts/$DomainName.conf
	                echo "   AddHandler x-httpd-php .php .php3 .php4 .php5" >> /etc/httpd/conf/vhosts/$DomainName.conf
	                echo "   suPHP_AddHandler x-httpd-php"   >> /etc/httpd/conf/vhosts/$DomainName.conf
	
	                echo "   CustomLog \"/home/$UserName/http-access.log\" combined" >> /etc/httpd/conf/vhosts/$DomainName.conf
	
	                echo "</VirtualHost>" >> /etc/httpd/conf/vhosts/$DomainName.conf
			
	



                        for NextParkedDomainName in $(mysql cpadmin -u root -p${Password} -se "SELECT fqdn FROM domains WHERE parent_domain_id = $DomainID AND deleted = 0 AND domain_type = 'parked';")
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
					echo "<VirtualHost $IP:443>" >> /etc/httpd/conf/vhosts/$DomainName.conf
					echo "  SSLEngine On" >> /etc/httpd/conf/vhosts/$DomainName.conf
					echo "  SSLProtocol -all +SSLv3 +TLSv1" >> /etc/httpd/conf/vhosts/$DomainName.conf
					echo "  SSLHonorCipherOrder On" >> /etc/httpd/conf/vhosts/$DomainName.conf
					echo "  SSLCipherSuite ALL:!aNULL:!ADH:!eNULL:!LOW:!EXP:RC4+RSA:+HIGH:+MEDIUM:!SSLv2:!EXPORT" >> /etc/httpd/conf/vhosts/$DomainName.conf
					echo "" >> /etc/httpd/conf/vhosts/$DomainName.conf

					if [ $UseSSL == 1 ]
					then
						echo "  SSLCertificateFile /etc/httpd/conf/ssl/$NextParkedDomainName.crt" >> /etc/httpd/conf/vhosts/$DomainName.conf
						echo "  SSLCertificateKeyFile /etc/httpd/conf/ssl/$NextParkedDomainName.key" >> /etc/httpd/conf/vhosts/$DomainName.conf
						echo "  SSLCACertificateFile /etc/httpd/conf/ssl/$CertChain" >> /etc/httpd/conf/vhosts/$DomainName.conf
					elif [ $UseSSL == 2 ]
					then
						echo "  SSLCertificateFile /etc/letsencrypt/live/$NextParkedDomainName/cert.pem" >> /etc/httpd/conf/vhosts/$DomainName.conf
						echo "  SSLCertificateKeyFile /etc/letsencrypt/live/$NextParkedDomainName/privkey.pem" >> /etc/httpd/conf/vhosts/$DomainName.conf
						echo "  SSLCACertificateFile /etc/letsencrypt/live/$NextParkedDomainName/fullchain.pem" >> /etc/httpd/conf/vhosts/$DomainName.conf
					fi

					echo "   DocumentRoot \"/home/$UserName/public_html\"" >> /etc/httpd/conf/vhosts/$DomainName.conf
					echo "   ServerName $DomainName" >> /etc/httpd/conf/vhosts/$DomainName.conf

					ServerAlias="www.$NextParkedDomainName mail.$NextParkedDomainName ftp.$NextParkedDomainName"
					echo "   ServerAlias $ServerAlias" >> /etc/httpd/conf/vhosts/$DomainName.conf


					echo  "" >> /etc/httpd/conf/vhosts/$DomainName.conf
					echo  "" >> /etc/httpd/conf/vhosts/$DomainName.conf

					echo  " <IfModule mod_security2.c>" >> /etc/httpd/conf/vhosts/$DomainName.conf

					for URI in $(mysql cpadmin -u root -p${Password} -se "SELECT DISTINCT(extra2) FROM server_settings WHERE deleted = 0 AND setting = 'modsec_whitelist' AND extra1 = '$DomainName';")
					do
						echo "          <LocationMatch \"$URI\">" >> /etc/httpd/conf/vhosts/$DomainName.conf


						for ModsecID in $(mysql cpadmin -u root -p${Password} -se "SELECT value FROM server_settings WHERE deleted = 0 AND setting = 'modsec_whitelist' AND extra1 = '$DomainName' AND extra2 = '$URI';")
						do
							echo "                  SecRuleRemoveById $ModsecID" >> /etc/httpd/conf/vhosts/$DomainName.conf
						done
						echo "          </LocationMatch>" >> /etc/httpd/conf/vhosts/$DomainName.conf
					done
					echo "  </IfModule>" >> /etc/httpd/conf/vhosts/$DomainName.conf


					echo  "" >> /etc/httpd/conf/vhosts/$DomainName.conf
					echo  "" >> /etc/httpd/conf/vhosts/$DomainName.conf





					echo "   suPHP_Engine on" >> /etc/httpd/conf/vhosts/$DomainName.conf
					echo "   suPHP_UserGroup $UserName $UserName" >> /etc/httpd/conf/vhosts/$DomainName.conf
					echo "   AddHandler x-httpd-php .php .php3 .php4 .php5" >> /etc/httpd/conf/vhosts/$DomainName.conf
					echo "   suPHP_AddHandler x-httpd-php"   >> /etc/httpd/conf/vhosts/$DomainName.conf

					echo "   CustomLog \"/home/$UserName/http-access.log\" combined" >> /etc/httpd/conf/vhosts/$DomainName.conf

					echo "   <Directory \"/home/$UserName/public_html\">" >> /etc/httpd/conf/vhosts/$DomainName.conf
					echo "      Options All" >> /etc/httpd/conf/vhosts/$DomainName.conf
					echo "      AllowOverride All" >> /etc/httpd/conf/vhosts/$DomainName.conf
					echo "      Order allow,deny" >> /etc/httpd/conf/vhosts/$DomainName.conf
					echo "      Allow from all" >> /etc/httpd/conf/vhosts/$DomainName.conf
					echo "   </Directory>" >> /etc/httpd/conf/vhosts/$DomainName.conf


					echo "  ScriptAlias /cgi-bin/ /home/$UserName/public_html/cgi-bin/" >> /etc/httpd/conf/vhosts/$DomainName.conf
					echo "  <Directory \"/home/$UserName/public_html/cgi-bin\">" >> /etc/httpd/conf/vhosts/$DomainName.conf
					echo "          AllowOverride None" >> /etc/httpd/conf/vhosts/$DomainName.conf
					echo "          Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch" >> /etc/httpd/conf/vhosts/$DomainName.conf
					echo "          Order allow,deny" >> /etc/httpd/conf/vhosts/$DomainName.conf
					echo "          Allow from all" >> /etc/httpd/conf/vhosts/$DomainName.conf
					echo "  </Directory>" >> /etc/httpd/conf/vhosts/$DomainName.conf


					echo "</VirtualHost>" >> /etc/httpd/conf/vhosts/$DomainName.conf
					echo ""
				fi
				
			done
		
			echo "Calling Subdomains...";
			/usr/webcp/subdomains.sh $DomainID $DomainName $UserName $DomainName $IP

			rm -fr $FullFileName
		
				Restart=1
		fi
	fi


done



if [ "$Restart" == "1" ]
then
	echo "doing gracefull restart"
	
	OldFile="/usr/webcp/templates/httpd.conf"
	NewFile="/etc/httpd/conf/httpd.conf"

	cat $OldFile | sed "s/NameVirtualHost \*:/NameVirtualHost $SharedIP:/" > $NewFile
        
	/etc/init.d/httpd graceful

fi

/usr/webcp/mkemail.sh

	
