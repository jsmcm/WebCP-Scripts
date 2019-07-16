#!/bin/bash

x=$(pgrep do_backup.sh | wc -w)
if [ $x -gt 2 ]; then
        exit
fi

Debug=0

RandomString=""
Type=""
EmailAddress=""

DomainName=""
DomainUserName=""
DomainPath=""
Daily=""
DailyFTPUse="off"
DailyFTPCount=1

Weekly=""
WeeklyFTPUse="off"
WeeklyFTPCount=1

Monthly=""
MonthlyFTPUse="off"
MonthlyFTPCount=1

Adhoc=""

Web=0
Mail=0

Password=`/usr/webcp/get_password.sh`

if [ ! -d "/var/www/html/backups/monthly" ]; then
        mkdir /var/www/html/backups/monthly
fi

if [ ! -d "/var/www/html/backups/weekly" ]; then
        mkdir /var/www/html/backups/weekly
fi

if [ ! -d "/var/www/html/backups/daily" ]; then
        mkdir /var/www/html/backups/daily
fi


for FullFileName in /var/www/html/webcp/nm/*.backup; 
do

	if [ -f $FullFileName ]
	then	
		echo $FullFileName
		x=$FullFileName
                echo "x: '$x'"
		y=${x%.backup}
                echo "y: '$y'"
		DomainID=${y##*/}
                echo "file: '$DomainID'"


		echo "Read: $FullFileName"
		while read line
		do

			if [ ! -z "$line" ]
			then

				if [[ "$line" == *"RandomString"* ]]; then				
					RandomString=$line

					RandomString=${RandomString##*RandomString=}
					echo "RandomString: '$RandomString'"
					
				elif [[ "$line" == *"EmailAddress"* ]]; then
					EmailAddress=$line
					
					EmailAddress=${EmailAddress##*EmailAddress=}
					echo "EmailAddress: '$EmailAddress'"
				
				elif [[ "$line" == *"Type"* ]]; then
					Type=$line
					
					Type=${Type##*Type=}
					echo "Type: '$Type'"

				elif [[ "$line" == *"DomainName"* ]]; then
					DomainName=$line
					
					DomainName=${DomainName##*DomainName=}
					echo "DomainName: '$DomainName'"
				
				elif [[ "$line" == *"DomainUserName"* ]]; then
					DomainUserName=$line
					
					DomainUserName=${DomainUserName##*DomainUserName=}
					echo "DomainUserName: '$DomainUserName'"

				elif [[ "$line" == *"DomainPath"* ]]; then
					DomainPath=$line
					
					DomainPath=${DomainPath##*DomainPath=}
					echo "DomainPath: '$DomainPath'"

				elif [[ "$line" == *"DailyFTPUse"* ]]; then
					DailyFTPUse=$line
					
					DailyFTPUse=${DailyFTPUse##*DailyFTPUse=}
					echo "DailyFTPUse: '$DailyFTPUse'"

				elif [[ "$line" == *"DailyFTPCount"* ]]; then
					DailyFTPCount=$line
					
					DailyFTPCount=${DailyFTPCount##*DailyFTPCount=}
					echo "DailyFTPCount: '$DailyFTPCount'"

                                elif [[ "$line" == *"Daily"* ]]; then
                                        Daily=$line
                          
                                        Daily=${Daily##*Daily=}
                                        echo "Daily: '$Daily'"
						
					if [[ "$Daily" == "all" ]]; then
						Web=1
						Mail=1
					elif [[ "$Daily" == "web" ]]; then
						Web=1
					elif [[ "$Daily" == "mail" ]]; then
						Mail=1
					fi			
		
                                elif [[ "$line" == *"WeeklyFTPUse"* ]]; then
                                        WeeklyFTPUse=$line

                                        WeeklyFTPUse=${WeeklyFTPUse##*WeeklyFTPUse=}
                                        echo "WeeklyFTPUse: '$WeeklyFTPUse'"

                                elif [[ "$line" == *"WeeklyFTPCount"* ]]; then
                                        WeeklyFTPCount=$line

                                        WeeklyFTPCount=${WeeklyFTPCount##*WeeklyFTPCount=}
                                        echo "WeeklyFTPCount: '$WeeklyFTPCount'"


                                  elif [[ "$line" == *"Weekly"* ]]; then
                                        Weekly=$line
                          
                                        Weekly=${Weekly##*Weekly=}
                                        echo "Weekly: '$Weekly'"
						
					if [[ "$Weekly" == "all" ]]; then
						Web=1
						Mail=1
					elif [[ "$Weekly" == "web" ]]; then
						Web=1
					elif [[ "$Weekly" == "mail" ]]; then
						Mail=1
					fi			
		



                                elif [[ "$line" == *"MonthlyFTPUse"* ]]; then
                                        MonthlyFTPUse=$line

                                        MonthlyFTPUse=${MonthlyFTPUse##*MonthlyFTPUse=}
                                        echo "MonthlyFTPUse: '$MonthlyFTPUse'"

                                elif [[ "$line" == *"MonthlyFTPCount"* ]]; then
                                        MonthlyFTPCount=$line

                                        MonthlyFTPCount=${MonthlyFTPCount##*MonthlyFTPCount=}
                                        echo "MonthlyFTPCount: '$MonthlyFTPCount'"


                                  elif [[ "$line" == *"Monthly"* ]]; then
                                       	Monthly=$line
                          
                                       	Monthly=${Monthly##*Monthly=}
                                        echo "Monthly: '$Monthly"

					if [[ "$Monthly" == "all" ]]; then
						Web=1
						Mail=1
					elif [[ "$Monthly" == "web" ]]; then
						Web=1
					elif [[ "$Monthly" == "mail" ]]; then
						Mail=1
					fi			
                                 
				elif [[ "$line" == *"Adhoc"* ]]; then
					Adhoc="all"
		
					Web=1
					Mail=1

                                elif [[ "$line" == *"FTPPassword"* ]]; then
                                        FTPPassword=$line
                          
                                        FTPPassword=${FTPPassword##*FTPPassword=}
                                        echo "FTPPassword: '$FTPPassword'"
                                elif [[ "$line" == *"FTPHost"* ]]; then
                                        FTPHost=$line
                          
                                        FTPHost=${FTPHost##*FTPHost=}
                                        echo "FTPHost: '$FTPHost'"
					
                                  elif [[ "$line" == *"FTPRemotePath"* ]]; then
                                        FTPRemotePath=$line
                          
                                        FTPRemotePath=${FTPRemotePath##*FTPRemotePath=}
                                        echo "FTPRemotePath: '$FTPRemotePath'"

                                elif [[ "$line" == *"FTPUserName"* ]]; then
                                        FTPUserName=$line
                          
                                        FTPUserName=${FTPUserName##*FTPUserName=}
                                        echo "FTPUserName: '$FTPUserName'"
					
                                elif [[ "$line" == *"FTPPassword"* ]]; then
                                        FTPPassword=$line
                          
                                        FTPPassword=${FTPPassword##*FTPPassword=}
                                        echo "FTPPassword: '$FTPPassword'"
				fi
					
			fi

		done <$FullFileName

		if [[ "$Web" == 1 ]]; then
			echo "Making Web files..."
		fi
		
		if [[ "$Mail" == 1 ]]; then
			echo "Making Mail files..."
		fi

		if [ ! -z "$RandomString" ]
		then

			if [ ! -z "$DomainUserName" ]
			then
				echo "RUNNING WITH Random: $RandomString and Domain User: $DomainUserName"

				
				if [[ "$Web" == 1 ]]; then
					/usr/webcp/backups/webtar.gz.sh $DomainUserName $RandomString			
					/usr/webcp/backups/mysql_dump.sh $DomainUserName $RandomString			
					/usr/bin/crontab -l -u ${DomainUserName} > /var/www/html/backups/tmp/$RandomString/cron.dat
				fi
				
				if [[ "$Mail" == 1 ]]; then
					/usr/webcp/backups/mailtar.gz.sh $DomainUserName $RandomString			
				fi

				chown www-data.www-data /var/www/html/backups/tmp/$RandomString -R
				chmod 755 /var/www/html/backups/tmp/$RandomString -R
			
				cd /var/www/html/backups/tmp/$RandomString


				FullFileExists=""
				WebFileExists=""
				MailFileExists=""

				if [[ "$Monthly" == "all" ]]; then

					if [[ -f /var/www/html/backups/monthly/$DomainUserName.tar.gz ]]; then
						rm -fr /var/www/html/backups/monthly/$DomainUserName.tar.gz
					fi

					echo "Creating Monthly full file"
					nice /bin/tar cvfz /var/www/html/backups/monthly/${DomainUserName}.tar.gz *.dat *_web.tar *.xml sql/* *_mail.tar
					FullFileExists="monthly"

				elif [[ "$Monthly" == "web" ]]; then

					if [[ -f /var/www/html/backups/monthly/$DomainUserName.tar.gz ]]; then
						rm -fr /var/www/html/backups/monthly/$DomainUserName.tar.gz
					fi

					echo "Creating Monthly web file"
					nice /bin/tar cvfz /var/www/html/backups/monthly/${DomainUserName}.tar.gz *.dat *_web.tar *.xml sql/*
					WebFileExists="monthly"

				elif [[ "$Monthly" == "mail" ]]; then
					if [[ -f /var/www/html/backups/monthly/$DomainUserName.tar.gz ]]; then
						rm -fr /var/www/html/backups/monthly/$DomainUserName.tar.gz
					fi

					echo "Creating Monthly mail file"
					nice /bin/tar cvfz /var/www/html/backups/monthly/${DomainUserName}.tar.gz *_mail.tar
					MailFileExists="monthly"

				fi			



                                if [[ "$Weekly" == "all" ]]; then

                                        if [[ -f /var/www/html/backups/weekly/$DomainUserName.tar.gz ]]; then
                                                rm -fr /var/www/html/backups/weekly/$DomainUserName.tar.gz
                                        fi

					if [ -z "$FullFileExists" ]
					then
						echo "Creating weekly full file"
	                                        nice /bin/tar cvfz /var/www/html/backups/weekly/${DomainUserName}.tar.gz *.dat *_web.tar *.xml sql/* *_mail.tar
						FullFileExists="weekly"
					else
						echo "Copying full file from ${FullFileExists}"
						nice cp /var/www/html/backups/${FullFileExists}/${DomainUserName}.tar.gz /var/www/html/backups/weekly
					fi

                                elif [[ "$Weekly" == "web" ]]; then

                                        if [[ -f /var/www/html/backups/weekly/$DomainUserName.tar.gz ]]; then
                                                rm -fr /var/www/html/backups/weekly/$DomainUserName.tar.gz
                                        fi

					if [ -z "$WebFileExists" ]
					then
						echo "Creating weekly web file"
	                                        nice /bin/tar cvfz /var/www/html/backups/weekly/${DomainUserName}.tar.gz *.dat *_web.tar *.xml sql/*
						WebFileExists="weekly"
					else
						echo "Copying web file from ${WebFileExists}"
						nice cp /var/www/html/backups/${WebFileExists}/${DomainUserName}.tar.gz /var/www/html/backups/weekly
					fi
			

                                elif [[ "$Weekly" == "mail" ]]; then
                                        if [[ -f /var/www/html/backups/weekly/$DomainUserName.tar.gz ]]; then
                                                rm -fr /var/www/html/backups/weekly/$DomainUserName.tar.gz
                                        fi

					if [ -z "$MailFileExists" ]
					then
						echo "Creating weekly mail file"
	                                        nice /bin/tar cvfz /var/www/html/backups/weekly/${DomainUserName}.tar.gz *_mail.tar
						MailFileExists="weekly"
					else
						echo "Copying mail file from ${MailFileExists}"
						nice cp /var/www/html/backups/${MailFileExists}/${DomainUserName}.tar.gz /var/www/html/backups/weekly
					fi
                                fi




                                if [[ "$Daily" == "all" ]]; then

                                        if [[ -f /var/www/html/backups/daily/$DomainUserName.tar.gz ]]; then
                                                rm -fr /var/www/html/backups/daily/$DomainUserName.tar.gz
                                        fi

                                        if [ -z "$FullFileExists" ]
                                        then
                                                echo "Creating daily full file"
                                                nice /bin/tar cvfz /var/www/html/backups/daily/${DomainUserName}.tar.gz *.dat *_web.tar *.xml sql/* *_mail.tar
                                                FullFileExists="daily"
                                        else
                                                echo "Copying full file from ${FullFileExists}"
                                                nice cp /var/www/html/backups/${FullFileExists}/${DomainUserName}.tar.gz /var/www/html/backups/daily
                                        fi

                                elif [[ "$Daily" == "web" ]]; then

                                        if [[ -f /var/www/html/backups/daily/$DomainUserName.tar.gz ]]; then
                                                rm -fr /var/www/html/backups/daily/$DomainUserName.tar.gz
                                        fi

                                        if [ -z "$WebFileExists" ]
                                        then
                                                echo "Creating daily web file"
                                                nice /bin/tar cvfz /var/www/html/backups/daily/${DomainUserName}.tar.gz *.dat *_web.tar *.xml sql/*
                                                WebFileExists="daily"
                                        else
                                                echo "Copying web file from ${WebFileExists}"
                                                nice cp /var/www/html/backups/${WebFileExists}/${DomainUserName}.tar.gz /var/www/html/backups/daily
                                        fi


                                elif [[ "$Daily" == "mail" ]]; then
                                        if [[ -f /var/www/html/backups/daily/$DomainUserName.tar.gz ]]; then
                                                rm -fr /var/www/html/backups/daily/$DomainUserName.tar.gz
                                        fi

                                        if [ -z "$MailFileExists" ]
                                        then
                                                echo "Creating daily mail file"
                                                nice /bin/tar cvfz /var/www/html/backups/daily/${DomainUserName}.tar.gz *_mail.tar
                                                MailFileExists="daily"
                                        else
                                                echo "Copying mail file from ${MailFileExists}"
                                                nice cp /var/www/html/backups/${MailFileExists}/${DomainUserName}.tar.gz /var/www/html/backups/daily
                                        fi
                                fi




                                if [[ "$Adhoc" == "all" ]]; then

                                        if [[ -f /var/www/html/backups/adhoc/$DomainUserName_$RandomString.tar.gz ]]; then
                                                rm -fr /var/www/html/backups/adhoc/$DomainUserName_$RandomString.tar.gz
                                        fi

                                        if [ -z "$FullFileExists" ]
                                        then
                                                echo "Creating adhoc full file"
                                                nice /bin/tar cvfz /var/www/html/backups/adhoc/${DomainUserName}_${RandomString}.tar.gz *.dat *_web.tar *.xml sql/* *_mail.tar
                                                FullFileExists="adhoc"
                                        else
                                                echo "Copying full file from ${FullFileExists}"
                                                nice cp /var/www/html/backups/${FullFileExists}/${DomainUserName}.tar.gz /var/www/html/backups/adhoc/$DomainUserName_$RandomString.tar.gz
                                        fi
				fi

				

				echo "rm -fr /var/www/html/backups/tmp/$RandomString"
				cd /var/www/html/backups/tmp
				rm -fr /var/www/html/backups/tmp/$RandomString
	
				echo "Chowning"	
				chown www-data.www-data /var/www/html/backups/monthly -R
				chown www-data.www-data /var/www/html/backups/weekly -R
				chown www-data.www-data /var/www/html/backups/daily -R
				chown www-data.www-data /var/www/html/backups/adhoc -R
				
		
				echo "chmod 755 /var/www/html/backups/ -R"
				chmod 755 /var/www/html/backups/monthly -R
				chmod 755 /var/www/html/backups/weekly -R
				chmod 755 /var/www/html/backups/daily -R
				chmod 755 /var/www/html/backups/adhoc -R

				echo "check if email address set ($EmailAddress)"
				if [ ! -z "$EmailAddress" ]
				then
					echo $HOME
					pwd
					echo "Calling send_email script"
					/usr/webcp/backups/send_email.sh $DomainUserName $EmailAddress ${DomainUserName}_${RandomString}.tar.gz
					echo "Mail sent"
				fi
	
			fi
		fi

		echo "rm -fr $FullFileName"
		rm -fr $FullFileName

	fi

	echo "Looping"


done


if [ "$DailyFTPUse" == "on" ]
then
	if [ ! -z "$FTPHost" ]
	then
		echo "Sending to daily FTP with $DailyFTPCount!"
		nice /usr/webcp/backups/ftp.sh $FTPHost $FTPUserName $FTPPassword $FTPRemotePath daily $DailyFTPCount
	fi
fi 

if [ "$WeeklyFTPUse" == "on" ]
then
	if [ ! -z "$FTPHost" ]
	then
		echo "Sending to weekly FTP with $WeeklyFTPCount!"
		nice /usr/webcp/backups/ftp.sh $FTPHost $FTPUserName $FTPPassword $FTPRemotePath weekly $WeeklyFTPCount
	fi
fi 

if [ "$MonthlyFTPUse" == "on" ]
then
	if [ ! -z "$FTPHost" ]
	then
		echo "Sending to monthly FTP with $MonthlyFTPCount!"
		nice /usr/webcp/backups/ftp.sh $FTPHost $FTPUserName $FTPPassword $FTPRemotePath monthly $MonthlyFTPCount
	fi
fi 


echo "Done"

