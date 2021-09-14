#!/bin/bash

x=$(pgrep do_restore.sh | wc -w)
if [ $x -gt 2 ]; then
        exit
fi

RandomString=""
UserName=""
Password=`/usr/webcp/get_password.sh`
DB_HOST=`/usr/webcp/get_db_host.sh`

for FullFileName in /var/www/html/webcp/nm/*.restore; 
do

	if [ -f $FullFileName ]
	then	

		echo "Read: $FullFileName"

		while read line
		do

			if [ ! -z "$line" ]
			then

				if [[ "$line" == *"RandomString"* ]]; then				
					echo "RandomString: '$line'"
					RandomString=$line

					RandomString=${RandomString##*RandomString=}
					echo "RandomString: '$RandomString'"
					
				elif [[ "$line" == *"UserName"* ]]; then
					echo "UserName: '$line'"
					UserName=$line
					
					UserName=${UserName##*UserName=}
					echo "UserName: '$UserName'"
				
				fi
					
			fi

		done <$FullFileName


		echo "Checking username and random string"

		if [ -z "$RandomString" ]
		then
			rm -fr $FullFileName
			echo "RandomString is blank!";

			exit
		fi

		if [ -z "$UserName" ]
		then
			rm -fr "/var/www/html/webcp/restore/tmp/$RandomString"
			rm -fr $FullFileName
			echo "Username is blank!"
			
			exit
		fi

		if [ ! -d "/home/$UserName" ]
		then
			# not created yet, exit for now
			echo "/home/$UserName does not exist yet, exiting for now..."
			exit
		fi

		
		echo "looking for existence of /var/www/html/webcp/restore/tmp/${RandomString}/${UserName}_web.tar"		
		if [ -f "/var/www/html/webcp/restore/tmp/${RandomString}/${UserName}_web.tar" ]
		then
	
			if [ "${#UserName}" -gt "4" ]
			then	
				rm -fr /home/$UserName/home/.passwd/*
				rm -fr /home/$UserName/home/public_html

				echo "cp /var/www/html/webcp/restore/tmp/${RandomString}/${UserName}_web.tar /home/"
				cp /var/www/html/webcp/restore/tmp/${RandomString}/${UserName}_web.tar /home/$UserName/home

				echo "cd /home/$UserName/home"
				cd /home/$UserName/home

				echo "/bin/tar xf /home/$UserName/home/${UserName}_web.tar"
				/bin/tar xf /home/$UserName/home/${UserName}_web.tar
		
				echo "rm -fr /home/$UserName/home/${UserName}_web.tar"
				rm -fr /home/$UserName/home/${UserName}_web.tar
			fi
		
		fi	


		if [ -f "/var/www/html/webcp/restore/tmp/${RandomString}/${UserName}_mail.tar" ]
		then
			if [ "${#UserName}" -gt "4" ]
			then	
				rm -fr /home/$UserName/home/mail
				echo "cp /var/www/html/webcp/restore/tmp/${RandomString}/${UserName}_mail.tar /home/${UserName}/home"
				cp /var/www/html/webcp/restore/tmp/${RandomString}/${UserName}_mail.tar /home/${UserName}/home

				echo "cd /home/${UserName}/home"
				cd /home/${UserName}/home

				echo "/bin/tar xf /home/${UserName}/home/${UserName}_mail.tar"
				/bin/tar xf /home/${UserName}/home/${UserName}_mail.tar
		
				echo "rm -fr /home/${UserName}/home/${UserName}_mail.tar"
				rm -fr /home/${UserName}/home/${UserName}_mail.tar
			fi	
		fi	

		/usr/bin/crontab -r -u ${UserName}
		/usr/bin/crontab -u ${UserName} /var/www/html/webcp/restore/tmp/${RandomString}/cron.dat

		

		echo "changin permission"
		chmod 755 /home/$UserName/home/mail -R
		chmod 755 /home/$UserName/home/.passwd -R
		chmod 770 /home/$UserName/home/.passwd
		
		
		echo "Changin owner to $UserName"
		chown $UserName.$UserName /home/$UserName/home/ -R

		chown www-data.www-data /home/$UserName/home/.passwd -R
		chown $UserName.$UserName /home/$UserName/home/.passwd/read.php
		chown $UserName.$UserName /home/$UserName/home/.passwd/write.php
		chown $UserName.apache /home/$UserName/home/.passwd

		# we read it once to get random string and username, then again
		# to get database.... should work in one shot, but if someone
		# makes this file by hand they could get the order wrong

		echo "Doing database imports"

                while read line
                do

                        if [ ! -z "$line" ]
                        then

                                if [[ "$line" == *"MySQL"* ]]; then               
                                        echo "MySQL: '$line'"
                                        MySQL=$line

                                        MySQL=${MySQL##*MySQL=}
                                        echo "MySQL: '$MySQL'"
					
					/usr/bin/mysql -u ${User} -p${Password} $MySQL -h ${DB_HOST} < /var/www/html/webcp/restore/tmp/$RandomString/sql/$MySQL.sql
					
                                fi

                        fi

                done <$FullFileName



		

		echo "removing $FullFileName"
		rm -fr $FullFileName

		
		echo "Removing /var/www/html/webcp/restore/rmp/$RandomString"
		rm -fr "/var/www/html/webcp/restore/tmp/$RandomString"

	fi



done

echo "Done"
