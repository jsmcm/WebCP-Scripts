#!/bin/bash


Host=$1
UserName=$2
Password=$3
RemotePath=$4
Type=$5
Count=$6

Failed=0

echo "The following FTP files failed to transfer: " > /tmp/webcp/failed_ftp
echo "" >> /tmp/webcp/failed_ftp

for FullFileName in /var/www/html/backups/$Type/*.tar.gz
do
        if [ -f $FullFileName ]
        then
		echo "/usr/webcp/backups/ftp_ins.sh $FullFileName $RemotePath $Host $UserName $Password $Type $Count"
		Result=`/usr/webcp/backups/ftp_ins.sh "$FullFileName" "$RemotePath" "$Host" "$UserName" "$Password" "$Type" "$Count"`

		FileSize=`ls -al --block-size=1 $FullFileName | awk '{print $5}'`
		FTPResult=0
		Test="
220 "
		if [[ $Result == *$Test* ]]
		then
			# connected
			Test="
226 "
			if [[ $Result == *$Test* ]]
			then
				# transfer complete
				Test="
$FileSize "
				if [[ $Result == *$Test* ]]
				then
					FTPResult=1
				fi
			fi
		fi

		if [ $FTPResult == 0 ]
		then
			Failed=1
			echo "FAILED: $FullFileName" >> /tmp/webcp/failed_ftp
		fi
	fi

done

if [ $Failed == 1 ]
then

	Password=`/usr/webcp/get_password.sh`	

	for EmailAddress in $(mysql cpadmin -u root -p${Password} -se "select email_address from admin where role ='admin';")
	do
		cat /tmp/webcp/failed_ftp | mutt -s "WebCP - FTP Failed" "$EmailAddress"
	done
fi
