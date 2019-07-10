#!/bin/bash

x=$(pgrep mkemail.sh | wc -w)
if [ $x -gt 2 ]; then
        exit
fi

mkdir -p /var/www/html/mail/domains

Password=`/usr/webcp/get_password.sh`



for FullFileName in /var/www/html/webcp/nm/*.nma; 
do

	if [ -f $FullFileName ]
	then	

		echo $FullFileName
		x=$FullFileName
		y=${x%.nma}
		UserName=${y##*/}
               	UserName=${UserName%_*}
		echo "UserName: $UserName"
                DomainName=$(mysql cpadmin -u root -p${Password} -se "SELECT fqdn FROM domains WHERE deleted = 0 AND UserName = '$UserName' AND domain_type = 'primary';")
                GroupID=$(mysql cpadmin -u root -p${Password} -se "SELECT Gid FROM domains WHERE deleted = 0 AND UserName = '$UserName' AND domain_type = 'primary';")
                UserID=$(mysql cpadmin -u root -p${Password} -se "SELECT Uid FROM domains WHERE deleted = 0 AND UserName = '$UserName' AND domain_type = 'primary';")

		echo "DomainName: $DomainName"
	
		Dir=`cat $FullFileName`
		echo $Dir
	
		if [ "${#Dir}" -gt "4" ]
		then
			echo "mkdir $Dir -p"
			mkdir $Dir -p
	
			echo "chmod 755 $Dir -R"
			chmod 755 $Dir -R
	
			echo "chown $UserName.$UserName $Dir -R"
			chown $UserName.$UserName $Dir -R
				
			
			echo "mkdir $Dir/cur"
			mkdir $Dir/cur
	
			echo "chmod 755 $Dir/cur -R"
			chmod 755 $Dir/cur -R
	
	
			echo "chown $UserName.$UserName $Dir/cur -R"
			chown $UserName.$UserName $Dir/cur -R
			
			echo "mkdir $Dir/new"
			mkdir $Dir/new
	
			echo "chmod 755 $Dir/new -R"
			chmod 755 $Dir/new -R
	
			/usr/webcp/email/drop_welcome_email.sh "$Dir/new" "$UserName@$DomainName"
			
			echo "chown $UserName.$UserName $Dir/new -R"
			chown $UserName.$UserName $Dir/new -R


			mkdir -p /var/www/html/mail/domains/$DomainName/forward
			echo "$UserName" > /var/www/html/mail/domains/$DomainName/username


			/usr/webcp/email/mkpasswdfiles.sh $DomainName $UserName $GroupID $UserID				
			chown www-data.www-data /var/www/html/mail/domains/$DomainName -R
			rm -fr $FullFileName
		fi
	fi

	service dovecot restart	

done

