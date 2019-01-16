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

		redirect=$(mysql cpadmin -u root -p${Password} -se "SELECT setting_value FROM domain_settings WHERE deleted = 0 AND domain_id = $DomainID;")
                  
                if [ "$redirect" == "" ]
                then
                    redirect="www"
                fi

		if [ "${#UserName}" -gt "4" ]
		then
	
			echo "groupadd $UserName -g $GroupID" > /home/domains.txt	
		        /usr/sbin/groupadd $UserName -g $GroupID
	
			echo "groupadd $UserName -g $GroupID" >> /home/domains.txt	
		        /usr/sbin/groupadd $UserName -g $GroupID
	
			# To add a password please see /usr/webcp/backups/mkdirs.sh
			echo "useradd -m -s /bin/bash -g $UserName -u $UserID  $UserName" >> /home/domains.txt
			/usr/sbin/useradd -m -s /bin/bash -g $UserName -u $UserID  $UserName

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

			echo "catch_workers_output = yes" >> /etc/php/7.0/fpm/pool.d/$UserName.conf
			echo "php_admin_value[error_log] = /home/$UserName/phperrors.log" >> /etc/php/7.0/fpm/pool.d/$UserName.conf
			echo "php_admin_flag[log_errors] = on" >> /etc/php/7.0/fpm/pool.d/$UserName.conf

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
				CertChain=`cat /var/www/html/webcp/nm/$DomainName.crtchain`
				echo "CertChain = $CertChain"
				rm -fr /var/www/html/webcp/nm/$DomainName.crtchain

				if [ $UseSSL == 1 ]
				then
					echo "	SSLCertificateFile /etc/nginx/ssl/$DomainName.crt" >> /etc/nginx/vhosts/$DomainName.conf
		                	echo "	SSLCertificateKeyFile /etc/nginx/ssl/$DomainName.key" >> /etc/nginx/vhosts/$DomainName.conf
		                	echo "	SSLCACertificateFile /etc/nginx/ssl/$CertChain" >> /etc/nginx/vhosts/$DomainName.conf
				fi




				#echo "server {" > /etc/nginx/sites-enabled/$DomainName.conf
				#echo "        listen 80;" >> /etc/nginx/sites-enabled/$DomainName.conf
				#echo "        listen [::]:80;" >> /etc/nginx/sites-enabled/$DomainName.conf
				#echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
				#echo "        server_name \$server_addr;" >> /etc/nginx/sites-enabled/$DomainName.conf
				#echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
				#echo "        return 301 http://www.$DomainName$request_uri;" >> /etc/nginx/sites-enabled/$DomainName.conf
				#echo "}" >> /etc/nginx/sites-enabled/$DomainName.conf

				echo "server {" >> /etc/nginx/sites-enabled/$DomainName.conf
				echo "        listen 80;" >> /etc/nginx/sites-enabled/$DomainName.conf
				echo "        server_name $DomainName;" >> /etc/nginx/sites-enabled/$DomainName.conf
				
				echo "        location /webcp {" >> /etc/nginx/sites-enabled/$DomainName.conf
				echo "                return 301 http://$DomainName:10025;" >> /etc/nginx/sites-enabled/$DomainName.conf
				echo "        }" >> /etc/nginx/sites-enabled/$DomainName.conf


				echo "        location /webmail {" >> /etc/nginx/sites-enabled/$DomainName.conf
				echo "                return 301 http://$DomainName:10030;" >> /etc/nginx/sites-enabled/$DomainName.conf
				echo "        }" >> /etc/nginx/sites-enabled/$DomainName.conf


				echo "        location /phpmyadmin {" >> /etc/nginx/sites-enabled/$DomainName.conf
				echo "                return 301 http://$DomainName:10035;" >> /etc/nginx/sites-enabled/$DomainName.conf
				echo "        }" >> /etc/nginx/sites-enabled/$DomainName.conf

				echo "        location / {" >> /etc/nginx/sites-enabled/$DomainName.conf

                                if [ "$redirect" == "naked" ]
                                then
				    echo "          return 301 https://$DomainName\$request_uri\$query_string;" >> /etc/nginx/sites-enabled/$DomainName.conf
                                else
				    echo "          return 301 https://www.$DomainName\$request_uri\$query_string;" >> /etc/nginx/sites-enabled/$DomainName.conf
                                fi
				echo "        }" >> /etc/nginx/sites-enabled/$DomainName.conf

				echo "}" >> /etc/nginx/sites-enabled/$DomainName.conf




				if [ $UseSSL == 1 ]
				then
					echo ""
				elif [ $UseSSL == 2 ]
				then
			                echo "server {" >> /etc/nginx/sites-enabled/$DomainName.conf
				        echo "	listen 443 ssl;" >> /etc/nginx/sites-enabled/$DomainName.conf
				        echo "	listen [::]:443 ssl;" >> /etc/nginx/sites-enabled/$DomainName.conf
	
					echo "	ssl_certificate /etc/letsencrypt/live/$DomainName/fullchain.pem;" >> /etc/nginx/sites-enabled/$DomainName.conf
					echo "	ssl_certificate_key /etc/letsencrypt/live/$DomainName/privkey.pem;" >> /etc/nginx/sites-enabled/$DomainName.conf
					echo "	ssl_trusted_certificate /etc/letsencrypt/live/$DomainName/fullchain.pem;" >> /etc/nginx/sites-enabled/$DomainName.conf
                                      
					echo "  include /etc/letsencrypt/options-ssl-nginx.conf;" >> /etc/nginx/sites-enabled/$DomainName.conf
    					echo "  ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;" >> /etc/nginx/sites-enabled/$DomainName.conf

  	                                if [ "$redirect" == "naked" ]
	                                then
				 		echo "        server_name www.$DomainName;" >> /etc/nginx/sites-enabled/$DomainName.conf
				    	else
				 		echo "        server_name $DomainName;" >> /etc/nginx/sites-enabled/$DomainName.conf
					fi

 					echo "        location / {" >> /etc/nginx/sites-enabled/$DomainName.conf

  	                                if [ "$redirect" == "naked" ]
	                                then
					    echo "          return 301 https://$DomainName\$request_uri\$query_string;" >> /etc/nginx/sites-enabled/$DomainName.conf
	                                else
					    echo "          return 301 https://www.$DomainName\$request_uri\$query_string;" >> /etc/nginx/sites-enabled/$DomainName.conf
	                                fi
					echo "        }" >> /etc/nginx/sites-enabled/$DomainName.conf
	
					echo "}" >> /etc/nginx/sites-enabled/$DomainName.conf

				fi
			fi



			echo "server {" >> /etc/nginx/sites-enabled/$DomainName.conf
			

			if [ $UseSSL != 0 ]
			then

				if [ $UseSSL == 1 ]
				then
					echo ""
				elif [ $UseSSL == 2 ]
				then
				        echo "	listen 443 ssl;" >> /etc/nginx/sites-enabled/$DomainName.conf
				        echo "	listen [::]:443 ssl;" >> /etc/nginx/sites-enabled/$DomainName.conf
	
					echo "	ssl_certificate /etc/letsencrypt/live/$DomainName/fullchain.pem;" >> /etc/nginx/sites-enabled/$DomainName.conf
					echo "	ssl_certificate_key /etc/letsencrypt/live/$DomainName/privkey.pem;" >> /etc/nginx/sites-enabled/$DomainName.conf
					echo "	ssl_trusted_certificate /etc/letsencrypt/live/$DomainName/fullchain.pem;" >> /etc/nginx/sites-enabled/$DomainName.conf
                                      
					echo "  include /etc/letsencrypt/options-ssl-nginx.conf;" >> /etc/nginx/sites-enabled/$DomainName.conf
    					echo "  ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;" >> /etc/nginx/sites-enabled/$DomainName.conf


				fi
			
			else
				echo "listen 80;" >> /etc/nginx/sites-enabled/$DomainName.conf
		        	echo "listen [::]:80;" >> /etc/nginx/sites-enabled/$DomainName.conf
			fi

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
			echo "location ~* ^.+\.(ogg|ogv|svg|svgz|eot|otf|woff|mp4|ttf|rss|atom|jpg|jpeg|gif|png|ico|zip|tgz|gz|rar|bz2|doc|xls|exe|ppt|tar|mid|midi|wav|bmp|rtf|css|js)\$ {" >> /etc/nginx/sites-enabled/$DomainName.conf
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


				echo "        location /webcp {" >> /etc/nginx/sites-enabled/$DomainName.conf
				echo "                return 301 http://$DomainName:10025;" >> /etc/nginx/sites-enabled/$DomainName.conf
				echo "        }" >> /etc/nginx/sites-enabled/$DomainName.conf


				echo "        location /webmail {" >> /etc/nginx/sites-enabled/$DomainName.conf
				echo "                return 301 http://$DomainName:10030;" >> /etc/nginx/sites-enabled/$DomainName.conf
				echo "        }" >> /etc/nginx/sites-enabled/$DomainName.conf


				echo "        location /phpmyadmin {" >> /etc/nginx/sites-enabled/$DomainName.conf
				echo "                return 301 http://$DomainName:10035;" >> /etc/nginx/sites-enabled/$DomainName.conf
				echo "        }" >> /etc/nginx/sites-enabled/$DomainName.conf


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



/usr/sbin/service nginx restart
/usr/sbin/service php7.0-fpm restart

/usr/webcp/email/mkemail.sh

	
