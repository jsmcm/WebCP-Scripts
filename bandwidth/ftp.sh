#!/bin/bash

Password=`cat /usr/webcp/password`
CurrentHour="$(date +"%H")"
CurrentTime="$(date +"%Y-%m-%d %H:%M:%S")"

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
