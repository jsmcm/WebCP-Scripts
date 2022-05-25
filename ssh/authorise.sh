#!/bin/bash

x=$(pgrep authorise.sh | wc -w)
if [ $x -gt 2 ]; then
        exit
fi

Password=`/usr/webcp/get_password.sh`
echo "password: $Password"

User=`/usr/webcp/get_username.sh`
echo "user: $User"

DB_HOST=`/usr/webcp/get_db_host.sh`
echo "db_host: $DB_HOST"



for FullFileName in /var/www/html/webcp/nm/*.authorise_domain_pub_key; 
do

	if [ -f $FullFileName ]
	then	
		echo $FullFileName
		x=$FullFileName
                echo "x: '$x'"
		y=${x%.authorise_domain_pub_key}
                echo "y: '$y'"
		domainId=${y##*/}
                echo "domainId: '$domainId'"

		domainUser=$(mysql cpadmin -u ${User} -p${Password} -h ${DB_HOST} -se "SELECT UserName FROM domains WHERE domains.deleted = 0 AND domains.id = $domainId;")
		echo "domainUser: $domainUser"

		path="/home/$domainUser/.ssh/";

		echo "domainUser: $domainUser"
		echo "path: $path"		

                if [ ! -d "$path" ]
                then
			echo "mkdir $path"
                        mkdir $path

			echo "chown $domainUser.$domainUser $path"
                        chown $domainUser.$domainUser $path

                        echo "chmod 700 $path"
                        chmod 700 $path
                fi

                if [ ! -d "/home/$domainUser/.ssh_hashes/"  ]
                then
                        echo "mkdir /home/$domainUser/.ssh_hashes/"
                        mkdir /home/$domainUser/.ssh_hashes/
                        
			echo "chown $domainUser.www-data /home/$domainUser/.ssh_hashes/"
                        chown $domainUser.www-data /home/$domainUser/.ssh_hashes/
                        
			echo "chmod 770 /home/$domainUser/.ssh_hashes/"
                        chmod 770 /home/$domainUser/.ssh_hashes/
                fi



		echo "rm ${path}authorized_keys"
		rm ${path}authorized_keys

		mysql cpadmin -u ${User} -p${Password} -h ${DB_HOST} -N -e "SELECT file_name FROM ssh WHERE deleted = 0 AND authorised = 1 AND domain_id = $domainId" | while read file_name; do

			fileName=${path}${file_name}.pub
			echo "fileName: $fileName"
			cat $fileName

			cat $fileName >> ${path}authorized_keys
	
			echo -e "\n" >> ${path}authorized_keys
	
		done


		echo "chown $domainUser.$domainUser ${path}authorized_keys"
		chown $domainUser.$domainUser ${path}authorized_keys

		echo "chmod 600 ${path}authorized_keys"
		chmod 600 ${path}authorized_keys
		
		echo "rm -fr $FullFileName"
		rm -fr $FullFileName
	fi

done




