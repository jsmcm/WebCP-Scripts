#!/bin/bash

x=$(pgrep delete_ssh.sh | wc -w)
if [ $x -gt 2 ]; then
        exit
fi

Password=`/usr/webcp/get_password.sh`

for FullFileName in /var/www/html/webcp/nm/*.delete_pub_key; 
do

	if [ -f $FullFileName ]
	then	
		echo $FullFileName
		x=$FullFileName
                echo "x: '$x'"
		y=${x%.delete_pub_key}
                echo "y: '$y'"
		keyId=${y##*/}
                echo "keyId: '$keyId'"

		fileName=$(mysql cpadmin -u root -p${Password} -se "SELECT file_name FROM ssh WHERE id = $keyId;")
		domainUser=$(mysql cpadmin -u root -p${Password} -se "SELECT UserName FROM domains, ssh WHERE domains.deleted = 0 AND domains.id = ssh.domain_id AND ssh.id = $keyId;")

		path="/home/$domainUser/.ssh/";

		if [ ! -d $path ]
		then
			mkdir $path
			chown $domainUser.$domainUser $path
			chmod 700 $path
		fi


                if [ ! -d "/home/$domainUser/.ssh_hashes/"  ]
                then
                        mkdir /home/$domainUser/.ssh_hashes/
                        chown $domainUser.www-data /home/$domainUser/.ssh_hashes/
                        chmod 770 /home/$domainUser/.ssh_hashes/
                fi



		echo "fileName: $fileName"
		echo "path: $path"

		rm ${path}${fileName}.pub
		rm -fr $FullFileName
	fi

done




