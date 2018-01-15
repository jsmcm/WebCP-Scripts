#!/bin/bash

Password=`cat /usr/webcp/password`
CurrentHour="$(date +"%H")"
CurrentTime="$(date +"%Y-%m-%d %H:%M:%S")"
CurrentDay="$(date +"%m%Y")"
CurrentDate="$(date +"%Y%m%d")"

for DomainName in $(mysql cpadmin -u root -p${Password} -se "SELECT DISTINCT(fqdn) FROM domains WHERE domain_type = 'primary' AND deleted = 0;")
do
	DomainUserName=$(mysql cpadmin -u root -p${Password} -se "SELECT UserName FROM domains WHERE domain_type = 'primary' AND deleted = 0 AND fqdn = '$DomainName';")
	FileName="/var/lib/awstats/awstats${CurrentDay}.${DomainName}.txt"
	LocalFileName="/tmp/${DomainName}.txt"
	cp $FileName $LocalFileName

	Start=0
	while read -r line;
	do     
		if [ "${line:0:9}" = "BEGIN_DAY" ]
		then
			Start=1
		fi

		if [ "${line:0:7}" = "END_DAY" ]
		then
			Start=0
		fi

		if [ $Start -eq 1 ]
		then

			if [ "${line:0:8}" = "$CurrentDate" ]
			then
				echo "$DomainUserName"
				line=`echo $line | cut -d' ' -f 4`
				echo "$line"

				SQL="DELETE FROM bandwidth WHERE domain_user_name = '$DomainUserName' AND service = 'http' AND time >= '$(date +"%Y-%m-%d") 00:00:00';"
				RESULT=$(mysql cpadmin -u root -p${Password} -se "$SQL")
				echo "$SQL"
				

				SQL="INSERT INTO bandwidth VALUES (0, '$DomainUserName', 'http', '$CurrentTime', $line, 0);"
				RESULT=$(mysql cpadmin -u root -p${Password} -se "$SQL")
				echo "$SQL"
			fi
		fi

	done < $LocalFileName

	rm $LocalFileName
done

exit

for FullFileName in /var/www/html/bandwidth/ftp/*; 
do

	if [ -f $FullFileName ]
	then	
		File=${FullFileName##*/}
                echo "file: '$File'"

		Hour=${File:0:2}
                echo "Hour: '$Hour'"

		DomainUserName=${File:3}
                echo "DomainUserName: '$DomainUserName'"

                echo "FullFileName: '$FullFileName'"

		echo "CurrentHour: '$CurrentHour'"

		if [ "$Hour" -ne "$CurrentHour" ]
		then
			sum=0
			while read -r line;
			do     
				(( sum += line ));
			done < $FullFileName
			
			echo $sum

			DomainName=$(mysql cpadmin -u root -p${Password} -se "INSERT INTO bandwidth VALUES (0, '$DomainUserName', 'ftp', '$CurrentTime', $sum, 0);")

			rm -fr $FullFileName
		fi
	
		echo ""


	fi

done

echo "Done"
exit
