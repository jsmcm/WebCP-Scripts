#!/bin/bash

x=$(pgrep domains.sh | wc -w)
if [ $x -gt 2 ]; then
        exit
fi

SkipRestartCheck=$1
Password=`/usr/webcp/get_password.sh`


Restart=0

SharedIP=""

for FullFileName in /var/www/html/webcp/nm/*.subdomain; 
do

	if [ -f $FullFileName ]
	then	
		if [ "$SharedIP" == "" ]
		then
			echo "mysql cpadmin -u root -p${Password} -se SELECT IFNULL(MIN(option_value), '*') FROM dns_options WHERE option_name = 'ip' AND deleted = 0 AND extra1 = 'shared' LIMIT 1;"
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


		if [ "${#UserName}" -gt "4" ]
		then
		
		        groupadd $UserName -g $GroupID
	
			# To add a password please see /usr/webcp/backups/mkdirs.sh
			echo "useradd -m -s /bin/bash -g $UserName -u $UserID  $UserName"
			useradd -m -s /bin/bash -g $UserName -u $UserID  $UserName

	                chmod 755 /home/$UserName
	                chown $UserName.$UserName /home/$UserName
	
	                chown $UserName.$UserName /home/$UserName/public_html
	                chmod 755 /home/$UserName/public_html
	
			echo "Setting $UserName to ${UserQuota%.*}" >> /home/q.txt
			setquota -u $UserName ${UserQuota%.*} ${UserQuota%.*} 0 0 -a ext4
	
	                chmod 755 /home/$UserName/.passwd -R
	                chmod 770 /home/$UserName/.passwd


	                chown www-data.www-data /home/$UserName/.passwd -R
	                chown $UserName.$UserName /home/$UserName/.passwd/read.php
	                chown $UserName.$UserName /home/$UserName/.passwd/write.php
	                chown $UserName.www-data /home/$UserName/.passwd

	
	                chmod 755 /home/$UserName/public_html/index.php
	                chown $UserName.$UserName /home/$UserName/public_html/index.php
	
	                mkdir /home/$UserName/mail
		
	                chmod 755 /home/$UserName/mail
	
	                chown $UserName.$UserName /home/$UserName/mail
	
	                mkdir /home/$UserName/mail/$DomainName
        	        
			chmod 755 /home/$UserName/mail/$DomainName
			
	                chown $UserName.$UserName /home/$UserName/mail/$DomainName
	

			
			echo "[$UserName]" > /etc/php/7.0/fpm/pool.d/$UserName.conf
			echo "" >> /etc/php/7.0/fpm/pool.d/$UserName.conf
			echo "user = $UserName" >> /etc/php/7.0/fpm/pool.d/$UserName.conf
			echo "group = $UserName" >> /etc/php/7.0/fpm/pool.d/$UserName.conf
			echo "" >> /etc/php/7.0/fpm/pool.d/$UserName.conf
			echo "listen = /run/php/php7.0-fpm-$UserName.sock" >> /etc/php/7.0/fpm/pool.d/$UserName.conf
			echo "" >> /etc/php/7.0/fpm/pool.d/$UserName.conf
			echo "listen.owner = www-data" >> /etc/php/7.0/fpm/pool.d/$UserName.conf
			echo "listen.group = www-data" >> /etc/php/7.0/fpm/pool.d/$UserName.conf
			echo "" >> /etc/php/7.0/fpm/pool.d/$UserName.conf
			echo "pm = dynamic" >> /etc/php/7.0/fpm/pool.d/$UserName.conf
			echo "pm.max_children = 25" >> /etc/php/7.0/fpm/pool.d/$UserName.conf
			echo "pm.start_servers = 3" >> /etc/php/7.0/fpm/pool.d/$UserName.conf
			echo "pm.min_spare_servers = 2" >> /etc/php/7.0/fpm/pool.d/$UserName.conf
			echo "pm.max_spare_servers = 5" >> /etc/php/7.0/fpm/pool.d/$UserName.conf
			echo "" >> /etc/php/7.0/fpm/pool.d/$UserName.conf


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




			echo "server {" > /etc/nginx/sites-enabled/$DomainName.conf
			echo "listen 80;" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "server_name \$server_addr;" >> /etc/nginx/sites-enabled/$DomainName.conf
    			echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
  			echo "return 301 http://$DomainName\$request_uri;" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "}" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "server {" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "listen 80;" >> /etc/nginx/sites-enabled/$DomainName.conf
		        echo "listen [::]:80;" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "	" >> /etc/nginx/sites-enabled/$DomainName.conf
		

			ServerAlias=""
			for NextParkedDomainName in $(mysql cpadmin -u root -p${Password} -se "SELECT fqdn FROM domains WHERE parent_domain_id = $DomainID AND deleted = 0 AND domain_type = 'parked';")
			do
				ServerAlias="$ServerAlias $NextParkedDomainName www.$NextParkedDomainName mail.$NextParkedDomainName ftp.$NextParkedDomainName"
	                
				# while we're looping through parked domains, create their mail directories
				mkdir /home/$UserName/mail/$NextParkedDomainName
	                
				chmod 755 /home/$UserName/mail/$NextParkedDomainName
			
		                chown $UserName.$UserName /home/$UserName/mail/$NextParkedDomainName
			done
			
			echo "server_name $DomainName www.$DomainName smtp.$DomainName pop.$DomainName imap.$DomainName mail.$DomainName ftp.$DomainName $ServerAlias;" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
		        echo "root /home/$UserName/public_html;" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
		        echo "index index.php index.html index.htm;" >> /etc/nginx/sites-enabled/$DomainName.conf
		        echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "location ~* ^.+\.(ogg|ogv|svg|svgz|eot|otf|woff|mp4|ttf|rss|atom|jpg|jpeg|gif|png|ico|zip|tgz|gz|rar|bz2|doc|xls|exe|ppt|tar|mid|midi|wav|bmp|rtf|css|js)$ {" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "	expires max;" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "}" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
		        echo "location / {" >> /etc/nginx/sites-enabled/$DomainName.conf
		        echo "        try_files \$uri \$uri/ /index.php?\$args;" >> /etc/nginx/sites-enabled/$DomainName.conf
		        echo "}" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
		        echo "location ~ \.php\$ {" >> /etc/nginx/sites-enabled/$DomainName.conf
		        echo "		include snippets/fastcgi-php.conf;" >> /etc/nginx/sites-enabled/$DomainName.conf
		        echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
		        echo "        fastcgi_pass unix:/run/php/php7.0-fpm-$UserName.sock;" >> /etc/nginx/sites-enabled/$DomainName.conf
		        echo "        fastcgi_send_timeout 300;" >> /etc/nginx/sites-enabled/$DomainName.conf
		        echo "        fastcgi_read_timeout 300;" >> /etc/nginx/sites-enabled/$DomainName.conf
		        echo "}" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
		        echo "location ~ /\.ht {" >> /etc/nginx/sites-enabled/$DomainName.conf
		        echo "        deny all;" >> /etc/nginx/sites-enabled/$DomainName.conf
		        echo "}" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "}" >> /etc/nginx/sites-enabled/$DomainName.conf	
			



			echo "server {" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "        listen 20010;" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "        listen [::]:20010;" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "        server_name $DomainName;" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "        root /home/$UserName/.editor;" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "	index index.php index.html index.htm;" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "        location / {" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "                try_files \$uri \$uri/ /index.php?\$args;" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "        }" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "        location ~ \.php\$ {" >> /etc/nginx/sites-enabled/$DomainName.conf
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
			echo "server {" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "        listen 20001;" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "        listen [::]:20001;" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "        server_name $DomainName;" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "        root /home/$UserName/.passwd;" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "	index index.php index.html index.htm;" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "        location / {" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "                try_files \$uri \$uri/ /index.php?\$args;" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "        }" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "        location ~ \.php\$ {" >> /etc/nginx/sites-enabled/$DomainName.conf
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
			echo "server {" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "        listen 20020;" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "        listen [::]:20020;" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "        server_name $DomainName;" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "        root /home/$UserName/.cron;" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "	index index.php index.html index.htm;" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "        location / {" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "                try_files \$uri \$uri/ /index.php?\$args;" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "        }" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "        location ~ \.php\$ {" >> /etc/nginx/sites-enabled/$DomainName.conf
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
			echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "server {" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "        listen 10030;" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "        listen [::]:10030;" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "        server_name $DomainName;" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "        root /var/www/html/rainloop;" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "	index index.php;" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "        location / {" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "                try_files \$uri \$uri/ /index.php?\$args;" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "        }" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "        location ~ \.php\$ {" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "                include snippets/fastcgi-php.conf;" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "                fastcgi_pass unix:/run/php/php7.0-fpm.sock;" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "                fastcgi_send_timeout 300;" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "                fastcgi_read_timeout 300;" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "        }" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "        location ~ /\.ht {" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "                deny all;" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "        }" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "}" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "server {" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "        listen 10035;" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "        listen [::]:10035;" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "        server_name $DomainName;" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "        root /var/www/html/phpmyadmin;" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "	index index.php;" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "        location / {" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "                try_files \$uri \$uri/ /index.php?\$args;" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "        }" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "        location ~ \.php\$ {" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "                include snippets/fastcgi-php.conf;" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "                fastcgi_pass unix:/run/php/php7.0-fpm.sock;" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "                fastcgi_send_timeout 300;" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "                fastcgi_read_timeout 300;" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "        }" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "        location ~ /\.ht {" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "                deny all;" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "        }" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "}" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "" >> /etc/nginx/sites-enabled/$DomainName.conf


			
	 
                        echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
                        echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
                        echo "server {" >> /etc/nginx/sites-enabled/$DomainName.conf
                        echo "        listen 10025;" >> /etc/nginx/sites-enabled/$DomainName.conf
                        echo "        listen [::]:10025;" >> /etc/nginx/sites-enabled/$DomainName.conf
                        echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
                        echo "        server_name $DomainName;" >> /etc/nginx/sites-enabled/$DomainName.conf
                        echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
                        echo "        root /var/www/html/webcp;" >> /etc/nginx/sites-enabled/$DomainName.conf
                        echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
                        echo "  index index.php;" >> /etc/nginx/sites-enabled/$DomainName.conf
                        echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
                        echo "        location / {" >> /etc/nginx/sites-enabled/$DomainName.conf
                        echo "                try_files \$uri \$uri/ /index.php?\$args;" >> /etc/nginx/sites-enabled/$DomainName.conf
                        echo "        }" >> /etc/nginx/sites-enabled/$DomainName.conf
                        echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
                        echo "        location ~ \.php\$ {" >> /etc/nginx/sites-enabled/$DomainName.conf
                        echo "                include snippets/fastcgi-php.conf;" >> /etc/nginx/sites-enabled/$DomainName.conf
                        echo "                fastcgi_pass unix:/run/php/php7.0-fpm.sock;" >> /etc/nginx/sites-enabled/$DomainName.conf
                        echo "                fastcgi_send_timeout 300;" >> /etc/nginx/sites-enabled/$DomainName.conf
                        echo "                fastcgi_read_timeout 300;" >> /etc/nginx/sites-enabled/$DomainName.conf
                        echo "        }" >> /etc/nginx/sites-enabled/$DomainName.conf
                        echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
                        echo "        location ~ /\.ht {" >> /etc/nginx/sites-enabled/$DomainName.conf
                        echo "                deny all;" >> /etc/nginx/sites-enabled/$DomainName.conf
                        echo "        }" >> /etc/nginx/sites-enabled/$DomainName.conf
                        echo "}" >> /etc/nginx/sites-enabled/$DomainName.conf
                        echo "" >> /etc/nginx/sites-enabled/$DomainName.conf



		
			echo "Calling Subdomains...";
			/usr/webcp/subdomains.sh $DomainID $DomainName $UserName $DomainName $IP

			rm -fr $FullFileName
		
				Restart=1
		fi
	fi


done



if [ "$Restart" == "1" ]
then
	service nginx reload
	service php7.0-fpm reload
fi

/usr/webcp/mkemail.sh

	
