#!/bin/bash

x=$(pgrep add_ssh.sh | wc -w)
if [ $x -gt 2 ]; then
        exit
fi

Password=`/usr/webcp/get_password.sh`

for FullFileName in /var/www/html/webcp/nm/*.add_pub_key; 
do

	if [ -f $FullFileName ]
	then	
		echo $FullFileName
		x=$FullFileName
                echo "x: '$x'"
		y=${x%.add_pub_key}
                echo "y: '$y'"
		keyId=${y##*/}
                echo "keyId: '$keyId'"

		fileName=$(mysql cpadmin -u root -p${Password} -se "SELECT file_name FROM ssh WHERE deleted = 0 AND id = $keyId;")
		domainUser=$(mysql cpadmin -u root -p${Password} -se "SELECT UserName FROM domains, ssh WHERE domains.deleted = 0 AND ssh.deleted = 0 AND domains.id = ssh.domain_id AND ssh.id = $keyId;")

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
			chmod 760 /home/$domainUser/.ssh_hashes/
		fi

		echo "fileName: $fileName"
		echo "path: $path"

		echo "mv $FullFileName ${path}${fileName}.pub"
		mv $FullFileName ${path}${fileName}.pub
		chown $domainUser.$domainUser ${path}${fileName}.pub
		chmod 600 ${path}${fileName}.pub
		#rm -fr $FullFileName
	fi

done




