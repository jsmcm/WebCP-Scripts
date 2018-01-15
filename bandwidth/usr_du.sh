#!/bin/bash
Password=`cat /usr/webcp/password`


	for DomainUserName in $(mysql cpadmin -u root -p${Password} -se "SELECT DISTINCT(UserName) FROM domains WHERE deleted = 0 AND domain_type = 'primary';")
	do
		echo ""                
		echo ""                
		echo "DomainUserName: $DomainUserName"

		DiskAllowance=$(mysql cpadmin -u root -p${Password} -se "SELECT value FROM domains, package_options WHERE domains.deleted = 0 AND package_options.deleted = 0 AND package_options.package_id = domains.package_id AND setting = 'DiskSpace' AND domains.UserName = '$DomainUserName' AND domains.domain_type = 'primary'")

		echo "DiskAllowance: $DiskAllowance"


		DiskUsage=`du -s -B 1 /home/$DomainUserName`

		DiskUsage=$(echo $DiskUsage | awk '{print $1}')

		echo "DiskUsage: $DiskUsage"

		Percentage=$(($DiskUsage * 100))
		echo "Percentage: $Percentage"

		Percentage=$(($Percentage / $DiskAllowance))
		echo "Percentage: $Percentage"

		HostName=`hostname`
		if [ $Percentage -gt 94 ]
		then

			MailSent=$(mysql cpadmin -u root -p${Password} -se "SELECT IFNULL(MIN(id), 0) FROM user_notices WHERE notice_type = '95_diskspace' AND user_name = '$DomainUserName' ")

			echo "MailSent: $MailSent"

			if [ $MailSent -eq 0 ]
			then
				URL="/usr/bin/wget http://localhost:10025/quota/SendDiskSpaceMail.php?DomainUserName=$DomainUserName&Percentage=$Percentage&HostName=$HostName"
				echo "/usr/bin/wget $URL"

			       	/usr/bin/wget -q -O /dev/null -o /dev/null $URL
                                $(mysql cpadmin -u root -p${Password} -se "INSERT INTO user_notices VALUES (0, '$DomainUserName', '95_diskspace', 1, '$(date +"%Y-%m-%d %H:%M:%S")') ")


			fi

		elif [ $Percentage -gt 79 ]
		then

			MailSent=$(mysql cpadmin -u root -p${Password} -se "SELECT IFNULL(MIN(id), 0) FROM user_notices WHERE notice_type = '80_diskspace' AND user_name = '$DomainUserName' ")

			echo "MailSent: $MailSent"

			if [ $MailSent -eq 0 ]
			then
				URL="/usr/bin/wget http://localhost:10025/quota/SendDiskSpaceMail.php?DomainUserName=$DomainUserName&Percentage=$Percentage&HostName=$HostName"
				echo "/usr/bin/wget $URL"
			       	
				/usr/bin/wget -q -O /dev/null -o /dev/null $URL
                                $(mysql cpadmin -u root -p${Password} -se "INSERT INTO user_notices VALUES (0, '$DomainUserName', '80_diskspace', 1, '$(date +"%Y-%m-%d %H:%M:%S")') ")
			fi

		elif [ $Percentage -lt 75 ]
		then
			MailSent=$(mysql cpadmin -u root -p${Password} -se "DELETE FROM user_notices WHERE notice_type IN ('80_diskspace', '95_diskspace') AND user_name = '$DomainUserName' ")

		fi

	done
                

echo "Done"
exit
