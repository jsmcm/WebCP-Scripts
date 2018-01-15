#!/bin/bash
Password=`cat /usr/webcp/password`


	for DomainUserName in $(mysql cpadmin -u root -p${Password} -se "SELECT DISTINCT(UserName) FROM domains WHERE deleted = 0 AND domain_type = 'primary';")
	do
                
		#echo "DomainUserName: $DomainUserName"

		TrafficAllowance=$(mysql cpadmin -u root -p${Password} -se "SELECT value FROM domains, package_options WHERE domains.deleted = 0 AND package_options.deleted = 0 AND package_options.package_id = domains.package_id AND setting = 'Traffic' AND domains.UserName = '$DomainUserName' AND domains.domain_type = 'primary'")

		#echo "TrafficAllowance: $TrafficAllowance"

		TrafficUsage=$(mysql cpadmin -u root -p${Password} -se "SELECT SUM(bandwidth) AS bandwidth FROM bandwidth WHERE domain_user_name = '$DomainUserName'")

		#echo "TrafficUsage: $TrafficUsage"

	        Scale="m"

	        while [ "$Scale" != "b" ]
	        do

	                if [ "$Scale" = "g" ]
	                then
	                        TrafficAllowance=$(($TrafficAllowance * 1024))
	                        Scale="m"

	                elif [ "$Scale" = "m" ]
	                then
	                        TrafficAllowance=$(($TrafficAllowance * 1024))
	                        Scale="k"

	                elif [ "$Scale" = "k" ]
	                then
        	                TrafficAllowance=$(($TrafficAllowance * 1024))
	                        Scale="b"

	                fi
	        done

		#echo "TrafficAllowance: $TrafficAllowance"

		TrafficUsage=$(($TrafficUsage * $TrafficAllowance))
		#echo "TrafficUsage: $TrafficUsage"

		Percentage=$(($TrafficUsage / $TrafficAllowance))
		#echo "Percentage: $Percentage"

		Percentage=$(($Percentage * 100))
		#echo "Percentage: $Percentage"

		Percentage=$(($Percentage / $TrafficAllowance))
		echo "Percentage: $Percentage"

		HostName=`hostname`
		if [ $Percentage -gt 94 ]
		then

			MailSent=$(mysql cpadmin -u root -p${Password} -se "SELECT IFNULL(MIN(id), 0) FROM user_notices WHERE notice_type = '95_traffic' AND user_name = '$DomainUserName' ")

			echo "MailSent: $MailSent"

			if [ $MailSent -eq 0 ]
			then
				URL="/usr/bin/wget http://localhost:10025/quota/SendTrafficMail.php?DomainUserName=$DomainUserName&Percentage=$Percentage&HostName=$HostName"
				echo "/usr/bin/wget $URL"
				/usr/bin/wget -q -O /dev/null -o /dev/null $URL
				$(mysql cpadmin -u root -p${Password} -se "INSERT INTO user_notices VALUES (0, '$DomainUserName', '95_traffic', 1, '$(date +"%Y-%m-%d %H:%M:%S")') ")
				
			fi

		elif [ $Percentage -gt 79 ]
		then

			MailSent=$(mysql cpadmin -u root -p${Password} -se "SELECT IFNULL(MIN(id), 0) FROM user_notices WHERE notice_type = '80_traffic' AND user_name = '$DomainUserName' ")

			echo "MailSent: $MailSent"

			if [ $MailSent -eq 0 ]
			then
				URL="/usr/bin/wget http://localhost:10025/quota/SendTrafficMail.php?DomainUserName=$DomainUserName&Percentage=$Percentage&HostName=$HostName"
				echo "/usr/bin/wget $URL"
				/usr/bin/wget -q -O /dev/null -o /dev/null $URL
				$(mysql cpadmin -u root -p${Password} -se "INSERT INTO user_notices VALUES (0, '$DomainUserName', '80_traffic', 1, '$(date +"%Y-%m-%d %H:%M:%S")') ")
				
			fi
		fi

	done
                

echo "Done"
exit
