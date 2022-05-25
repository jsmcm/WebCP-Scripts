#!/bin/bash

#mkpassword.sh is called from mkemail.sh so no need for this, it causes double entries in the password files

x=$(pgrep passwordwrapper.sh | wc -w)
if [ $x -gt 2 ]; then
        exit
fi

Password=`/usr/webcp/get_password.sh`
User=`/usr/webcp/get_username.sh`
DB_HOST=`/usr/webcp/get_db_host.sh`

for FullFileName in /var/www/html/webcp/nm/*.mailpassword; 
do

	if [ -f $FullFileName ]
	then	

		#echo $FullFileName
		x=$FullFileName
		y=${x%.mailpassword}
		UserName=${y##*/}
               	UserName=${UserName%_*}
                DomainName=$(mysql cpadmin -u ${User} -p${Password} -h ${DB_HOST} -se "SELECT fqdn FROM domains WHERE deleted = 0 AND UserName = '$UserName' AND domain_type = 'primary';")
                GroupID=$(mysql cpadmin -u ${User} -p${Password} -h ${DB_HOST} -se "SELECT Gid FROM domains WHERE deleted = 0 AND UserName = '$UserName' AND domain_type = 'primary';")
                UserID=$(mysql cpadmin -u ${User} -p${Password} -h ${DB_HOST} -se "SELECT Uid FROM domains WHERE deleted = 0 AND UserName = '$UserName' AND domain_type = 'primary';")

		echo "DomainName: $DomainName"
		echo "UserName: $UserName"
		echo "Guid: $GroupID"
		echo "Uid: $UserID"
		
		/usr/webcp/email/mkpasswdfiles.sh $DomainName $UserName $GroupID $UserID				
		rm -fr $FullFileName
				
	fi
	

done

