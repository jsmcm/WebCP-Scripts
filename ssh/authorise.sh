#!/bin/bash

x=$(pgrep authorise.sh | wc -w)
if [ $x -gt 2 ]; then
        exit
fi

Password=`/usr/webcp/get_password.sh`

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

		domainUser=$(mysql cpadmin -u root -p${Password} -se "SELECT UserName FROM domains WHERE domains.deleted = 0 AND domains.id = $domainId;")
		path="/home/$domainUser/.ssh/";
		

                if [ ! -d "$path" ]
                then
                        mkdir $path
                        chown $domainUser.$domainUser $path
                        chmod 700 $path
                fi

                if [ ! -d "/home/$domainUser/.ssh_hashes/"  ]
                then
                        mkdir /home/$domainUser/.ssh_hashes/
                        chown $domainUser.www-data /home/$domainUser/.ssh_hashes/
                        chmod 760 /home/$domainUser/.ssh_hashes/
                fi



		rm ${path}authorized_keys

		mysql cpadmin -u root -p${Password} -N -e "SELECT file_name FROM ssh WHERE deleted = 0 AND authorised = 1 AND domain_id = $domainId" | while read file_name; do
			fileName=${path}${file_name}.pub
			cat $fileName >> ${path}authorized_keys
			echo -e "\n" >> ${path}authorized_keys
		done


		chown $domainUser.$domainUser ${path}authorized_keys
		chmod 600 ${path}authorized_keys
		rm -fr $FullFileName
	fi

done




