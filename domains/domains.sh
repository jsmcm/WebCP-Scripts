#!/bin/bash

x=$(pgrep domains.sh | wc -w)
if [ $x -gt 2 ]; then
        exit
fi

SkipRestartCheck=$1
Password=`/usr/webcp/get_password.sh`
User=`/usr/webcp/get_username.sh`
DB_HOST=`/usr/webcp/get_db_host.sh`


defaultPHPVersion=`php -v | grep PHP\ [7,8] | cut -d ' ' -f 2 | cut -d '.' -f1,2`


Restart=0

SharedIP=""
sslRedirect=""
pagespeed="off"

for FullFileName in /var/www/html/webcp/nm/*.subdomain; 
do

	if [ -f $FullFileName ]
	then	
		if [ "$SharedIP" == "" ]
		then
			echo "mysql cpadmin -u ${User} -p${Password} -h ${DB_HOST} -se SELECT IFNULL(MIN(option_value), '*') FROM dns_options WHERE option_name = 'ip' AND deleted = 0 AND extra1 = 'shared' LIMIT 1;"
			SharedIP=$(mysql cpadmin -u ${User} -p${Password} -h ${DB_HOST} -se "SELECT IFNULL(MIN(option_value), '*') FROM dns_options WHERE option_name = 'ip' AND deleted = 0 AND extra1 = 'shared' LIMIT 1;")
			echo "SharedIP: $SharedIP"
		fi

		##echo $FullFileName
		x=$FullFileName
                echo "x: '$x'"
		y=${x%.subdomain}
                echo "y: '$y'"
		DomainID=${y##*/}
                echo "file: '$DomainID'"

		DomainName=$(mysql cpadmin -u ${User} -p${Password} -h ${DB_HOST} -se "SELECT fqdn FROM domains WHERE deleted = 0 AND id = $DomainID;")
		UserName=$(mysql cpadmin -u ${User} -p${Password} -h ${DB_HOST} -se "SELECT UserName FROM domains WHERE deleted = 0 AND id = $DomainID;")
		GroupID=$(mysql cpadmin -u ${User} -p${Password} -h ${DB_HOST} -se "SELECT Gid FROM domains WHERE deleted = 0 AND id = $DomainID;")
		UserID=$(mysql cpadmin -u ${User} -p${Password} -h ${DB_HOST} -se "SELECT Uid FROM domains WHERE deleted = 0 AND id = $DomainID;")
		#domainType=$(mysql cpadmin -u ${User} -p${Password} -h ${DB_HOST} -se "SELECT domain_type FROM domains WHERE deleted = 0 AND id = $DomainID;")
		#path=$(mysql cpadmin -u ${User} -p${Password} -h ${DB_HOST} -se "SELECT path FROM domains WHERE deleted = 0 AND id = $DomainID;")
		UserQuota=$(mysql cpadmin -u ${User} -p${Password} -h ${DB_HOST} -se "SELECT (value / 1024) FROM domains, package_options WHERE domains.deleted = 0 AND package_options.deleted = 0 AND package_options.package_id = domains.package_id AND package_options.setting = 'DiskSpace' AND domains.UserName = '$UserName' AND domains.domain_type = 'primary';")

		php=$(mysql cpadmin -u ${User} -p${Password} -h ${DB_HOST} -se "SELECT setting_value FROM domain_settings WHERE deleted = 0 AND setting_name = 'php_version' AND domain_id = $DomainID;")

		clientPHPVersion=$defaultPHPVersion

		if [ ! -z "$php" ]
		then
        		clientPHPVersion=$php
		fi

		echo "DomainID: $DomainID"
		echo "clientPHPVersion: $clientPHPVersion"
		echo "defaultPHPVersion: $defaultPHPVersion"
		echo "php: $php"



		#emailAddress==$(mysql cpadmin -u ${User} -p${Password} -h ${DB_HOST} -se "select email_address from admin where id = (select client_id from domains where id = $DomainID and deleted = 0);")

		IP=$(mysql cpadmin -u ${User} -p${Password} -h ${DB_HOST} -se "SELECT option_value FROM dns_options WHERE option_name = 'ip' AND extra1 = '$DomainName' AND deleted = 0 UNION  SELECT IFNULL(MIN(option_value), '*') FROM dns_options WHERE option_name = 'ip' AND deleted = 0 AND extra1 = 'shared' AND NOT EXISTS (SELECT option_value FROM dns_options WHERE option_name = 'ip' AND extra1 = '$DomainName' AND deleted = 0) LIMIT 1;")

		redirect=$(mysql cpadmin -u ${User} -p${Password} -h ${DB_HOST} -se "SELECT setting_value FROM domain_settings WHERE deleted = 0 AND setting_name = 'domain_redirect' AND domain_id = $DomainID;")
		sslRedirect=$(mysql cpadmin -u ${User} -p${Password} -h ${DB_HOST} -se "SELECT setting_value FROM domain_settings WHERE deleted = 0 AND setting_name = 'ssl_redirect' AND domain_id = $DomainID;")
		pagespeedBuffer=$(mysql cpadmin -u ${User} -p${Password} -h ${DB_HOST} -se "SELECT setting_value FROM domain_settings WHERE deleted = 0 AND setting_name = 'pagespeed' AND domain_id = $DomainID;")
		webp=$(mysql cpadmin -u ${User} -p${Password} -h ${DB_HOST} -se "SELECT setting_value FROM domain_settings WHERE deleted = 0 AND setting_name = 'auto_webp' AND domain_id = $DomainID;")
		useCache=$(mysql cpadmin -u ${User} -p${Password} -h ${DB_HOST} -se "SELECT setting_value FROM domain_settings WHERE deleted = 0 AND setting_name = 'fastcgi_cache' AND domain_id = $DomainID;")
	 	publicPath=$(mysql cpadmin -u ${User} -p${Password} -h ${DB_HOST} -se "SELECT setting_value FROM domain_settings WHERE deleted = 0 AND setting_name = 'public_path' AND domain_id = $DomainID;")

		if [ "$publicPath" == "" ]
		then
			publicPath="public_html"
		fi

                
		accessControlAllowOrigin=$(mysql cpadmin -u ${User} -p${Password} -h ${DB_HOST} -se "SELECT setting_value FROM domain_settings WHERE deleted = 0 AND setting_name = 'access_control_allow_origin' AND domain_id = $DomainID;")
		accessControlAllowMethods=$(mysql cpadmin -u ${User} -p${Password} -h ${DB_HOST} -se "SELECT setting_value FROM domain_settings WHERE deleted = 0 AND setting_name = 'access_control_allow_methods' AND domain_id = $DomainID;")
		accessControlAllowHeaders=$(mysql cpadmin -u ${User} -p${Password} -h ${DB_HOST} -se "SELECT setting_value FROM domain_settings WHERE deleted = 0 AND setting_name = 'access_control_allow_headers' AND domain_id = $DomainID;")
		accessControlExposeHeaders=$(mysql cpadmin -u ${User} -p${Password} -h ${DB_HOST} -se "SELECT setting_value FROM domain_settings WHERE deleted = 0 AND setting_name = 'access_control_expose_headers' AND domain_id = $DomainID;")



		
		if [ "$pagespeedBuffer" == "on" ]
		then
			pagespeed="on"
		fi

		echo "pagespeed 2: '$pagespeed'"
		echo "UserName: $UserName"

		if [ "${#UserName}" -gt "4" ]
		then

			userdel $UserName
			groupdel $UserName

			#echo "groupadd $UserName -g $GroupID" > /home/domains.txt	
		        /usr/sbin/groupadd $UserName -g $GroupID
	
			#echo "groupadd $UserName -g $GroupID" >> /home/domains.txt	
		        /usr/sbin/groupadd $UserName -g $GroupID
	

			# To add a password please see /usr/webcp/backups/mkdirs.sh
			#echo "useradd -m -s /bin/bash -g $UserName -u $UserID  $UserName" >> /home/domains.txt
			/usr/sbin/useradd -m -s /bin/bash -g $UserName -u $UserID  $UserName

			chown root.root /home/$UserName
	                chmod 755 /home/$UserName

			mkdir /home/$UserName/home/$UserName -p
			cp -fr /home/$UserName/.bashrc /home/$UserName/home/$UserName/
			cp -fr /home/$UserName/.bash_logout /home/$UserName/home/$UserName/
			cp -fr /home/$UserName/.profile /home/$UserName/home/$UserName/

			mkdir /home/$UserName/tmp -p
                        chown $UserName.$UserName /home/$UserName/tmp
	                chmod 775 /home/$UserName/tmp -R

			echo "Setting $UserName to ${UserQuota%.*}" >> /home/q.txt
			setquota -u $UserName ${UserQuota%.*} ${UserQuota%.*} 0 0 -a ext4
	
	                chmod 755 /home/$UserName/home/.passwd -R
	                chmod 770 /home/$UserName/home/.passwd


                        mkdir /home/$UserName/.ssh
                        chown $UserName.$UserName /home/$UserName/.ssh
                        chmod 700 /home/$UserName/.ssh

                        mkdir /home/$UserName/.ssh_hashes/
                        chown $UserName.www-data /home/$UserName/.ssh_hashes/
                        chmod 770 /home/$UserName/.ssh_hashes/
                

	                chown www-data.www-data /home/$UserName/.passwd -R
	                chown $UserName.$UserName /home/$UserName/.passwd/read.php
	                chown $UserName.$UserName /home/$UserName/.passwd/write.php
	                chown $UserName.www-data /home/$UserName/.passwd

	
			if [ ! -f "/home/$UserName/home/$UserName/${publicPath}/index.php" ] && [ ! -f "/home/$UserName/home/$UserName/${publicPath}/index.htm" ] && [ ! -f "/home/$UserName/home/$UserName/${publicPath}/index.html" ]
			then

				useFailSafe=0

				if [ ! -d "/var/www/html/webcp/skel/public_html" ]
				then
					useFailSafe=1
					mkdir /home/$UserName/home/$UserName/public_html -p
					cp /var/www/html/webcp/skel/failsafe /home/$UserName/home/$UserName/${publicPath}/index.php
				fi


				if [ ! -f "/var/www/html/webcp/skel/public_html/index.php" ] && [ ! -f "/var/www/html/webcp/skel/public_html/index.htm" ] && [ ! f "/var/www/html/webcp/skel/public_html/index.html" ]
				then
					useFailSafe=1
					cp /var/www/html/webcp/skel/failsafe /home/$UserName/home/$UserName/${publicPath}/index.php
				fi


				if [ $useFailSafe == 0 ]
				then
					cp -fr /var/www/html/webcp/skel/public_html /home/$UserName/home/$UserName/
				fi

			fi

	                chown $UserName.$UserName /home/$UserName/home -R
	                chmod 755 /home/$UserName/home -R
	
		
			if [ -d "/home/$UserName/.cron" ]
			then
        			mv -f /home/$UserName/.cron /home/$UserName/home/$UserName
        			mv -f /home/$UserName/.editor /home/$UserName/home/$UserName
        			mv -f /home/$UserName/.passwd /home/$UserName/home/$UserName
			fi

	
	                mkdir /home/$UserName/home/$UserName/mail
		
	                chmod 755 /home/$UserName/home/$UserName/mail
	
	                chown $UserName.$UserName /home/$UserName/home/$UserName/mail
	
	                mkdir /home/$UserName/home/$UserName/mail/$DomainName
        	        
			chmod 755 /home/$UserName/home/$UserName/mail/$DomainName
			
	                chown $UserName.$UserName /home/$UserName/home/$UserName/mail/$DomainName
	

		        mkdir /var/lib/php/sessions/$UserName
	                chown $UserName.$UserName /var/lib/php/sessions/$UserName/

			/usr/webcp/domains/mount.sh $UserName $UserID

			for phpDirectory in /etc/php/*;
			do

        			phpVersion=${phpDirectory##*/}
        			rm /etc/php/$phpVersion/fpm/pool.d/$UserName.conf

			done

			echo "[$UserName]" > /etc/php/$clientPHPVersion/fpm/pool.d/$UserName.conf
			echo "" >> /etc/php/$clientPHPVersion/fpm/pool.d/$UserName.conf

			echo "catch_workers_output = yes" >> /etc/php/$clientPHPVersion/fpm/pool.d/$UserName.conf
			echo "php_admin_value[open_basedir] = /home/$UserName/home/$UserName/:/home/$UserName/:/var/www/html/editor/:/tmp" >> /etc/php/$clientPHPVersion/fpm/pool.d/$UserName.conf

			echo "php_admin_value[error_log] = /home/$UserName/home/$UserName/phperrors.log" >> /etc/php/$clientPHPVersion/fpm/pool.d/$UserName.conf
			echo "php_admin_value[session.save_path] = /var/lib/php/sessions/$UserName" >> /etc/php/$clientPHPVersion/fpm/pool.d/$UserName.conf
			echo "php_admin_flag[log_errors] = on" >> /etc/php/$clientPHPVersion/fpm/pool.d/$UserName.conf

                        length=${#clientPHPVersion}
                        length=$((length + 6))

                        mysql cpadmin -u ${User} -p${Password} -h ${DB_HOST} -se "select substr(setting_name, $length), setting_value from domain_settings where domain_id =$DomainID AND deleted = 0 AND setting_name like 'php_${clientPHPVersion}_%';" | while read settingName settingValue; do
			     echo "php_admin_value[$settingName] = $settingValue" >> /etc/php/$clientPHPVersion/fpm/pool.d/$UserName.conf
                        done



			echo "user = $UserName" >> /etc/php/$clientPHPVersion/fpm/pool.d/$UserName.conf
			echo "group = $UserName" >> /etc/php/$clientPHPVersion/fpm/pool.d/$UserName.conf
			echo "" >> /etc/php/$clientPHPVersion/fpm/pool.d/$UserName.conf
			echo "listen = /run/php/php$clientPHPVersion-fpm-$UserName.sock" >> /etc/php/$clientPHPVersion/fpm/pool.d/$UserName.conf
			echo "" >> /etc/php/$clientPHPVersion/fpm/pool.d/$UserName.conf
			echo "listen.owner = www-data" >> /etc/php/$clientPHPVersion/fpm/pool.d/$UserName.conf
			echo "listen.group = www-data" >> /etc/php/$clientPHPVersion/fpm/pool.d/$UserName.conf
			echo "" >> /etc/php/$clientPHPVersion/fpm/pool.d/$UserName.conf
		




                        #set the defaults
                        declare -A php_pm=()
                        php_pm[max_children]="25"
                        php_pm[start_servers]=3
                        php_pm[min_spare_servers]=2
                        php_pm[max_spare_servers]=5
                        php_pm[max_requests]=1000

                        #now override from the db is set
                        length=${#clientPHPVersion}
                        length=$((length + 9))

                        while read settingName settingValue; do

		            if [ "$settingName" != "" ]
	                    then
                                php_pm[$settingName]="$settingValue"
                            fi

                        done<<<$(mysql cpadmin -u ${User} -p${Password} -h ${DB_HOST} -se "select substr(setting_name, $length), setting_value from domain_settings where domain_id =$DomainID AND deleted = 0 AND setting_name like 'php_pm_${clientPHPVersion}_%';")


			echo "pm = dynamic" >> /etc/php/$clientPHPVersion/fpm/pool.d/$UserName.conf
                        echo "pm.max_children = ${php_pm[max_children]}" >> /etc/php/$clientPHPVersion/fpm/pool.d/$UserName.conf
                        echo "pm.start_servers = ${php_pm[start_servers]}" >> /etc/php/$clientPHPVersion/fpm/pool.d/$UserName.conf
                        echo "pm.min_spare_servers = ${php_pm[min_spare_servers]}" >> /etc/php/$clientPHPVersion/fpm/pool.d/$UserName.conf
                        echo "pm.max_spare_servers = ${php_pm[max_spare_servers]}" >> /etc/php/$clientPHPVersion/fpm/pool.d/$UserName.conf
                        echo "pm.max_requests = ${php_pm[max_requests]}" >> /etc/php/$clientPHPVersion/fpm/pool.d/$UserName.conf

			
			
			echo "" >> /etc/php/$clientPHPVersion/fpm/pool.d/$UserName.conf

			echo "In domains.sh clientPHPVersion: $clientPHPVersion"

			/usr/webcp/domains/nginx.sh "$DomainID" "$DomainName" "$UserName" "$IP" "$redirect" "$sslRedirect" "$clientPHPVersion" "$pagespeed" "$webp" "$useCache" "$publicPath" "$accessControlAllowOrigin" "$accessControlAllowMethods" "$accessControlAllowHeaders" "$accessControlExposeHeaders"
		
			echo "Calling Subdomains...";
			/usr/webcp/domains/subdomains.sh "$DomainID" "$DomainName" "$UserName" "$IP" "$sslRedirect" "$clientPHPVersion" "$pagespeed" "$webp" "$useCache" "$publicPath" "$accessControlAllowOrigin" "$accessControlAllowMethods" "$accessControlAllowHeaders" "$accessControlExposeHeaders" 
			/usr/webcp/domains/parkeddomains.sh "$DomainID" "$DomainName" "$UserName" "$IP" "$sslRedirect" "$clientPHPVersion" "$webp" "$useCache" "$publicPath" "$accessControlAllowOrigin" "$accessControlAllowMethods" "$accessControlAllowHeaders" "$accessControlExposeHeaders" 
	
			Restart=1
		fi
			
		rm -fr $FullFileName
	fi

done

/usr/sbin/service nginx reload

for phpDirectory in /etc/php/*;
do

        phpVersion=${phpDirectory##*/}
        /usr/sbin/service php$phpVersion-fpm reload

done

/usr/webcp/email/mkemail.sh
/usr/webcp/domains/rename_tmp_free_ssl.sh
/usr/webcp/domains/make_hosts.sh
/usr/webcp/domains/remove-duplicate-mounts.sh

if [ -f "/var/www/html/webcp/nm/$DomainName.crtchain" ]
	then
		rm -fr /var/www/html/webcp/nm/$DomainName.crtchain
	fi
