#!/bin/bash

RemotePath=$1
Type=$2
Count=$3

Failed=0

echo "The following AWS files failed to transfer: " > /tmp/webcp/failed_aws
echo "" >> /tmp/webcp/failed_aws
discard=`/usr/local/bin/aws s3 mb s3://$RemotePath`

for FullFileName in /var/www/html/backups/$Type/*.tar.gz
do
        if [ -f $FullFileName ]
        then
		Result=`/usr/webcp/backups/aws_ins.sh "$FullFileName" "$RemotePath" "$Type" "$Count" |  cut -d$'\r' -f 2 | cut -c1-6`


		AWSResult=0

		if [[ $Result == "upload" ]]
		then
			AWSResult=1
		fi

		if [ $AWSResult == 0 ]
		then
			Failed=1
			echo "FAILED: $FullFileName" >> /tmp/webcp/failed_aws
		fi
	fi

done

if [ $Failed == 1 ]
then

	Password=`/usr/webcp/get_password.sh`	

	for EmailAddress in $(mysql cpadmin -u root -p${Password} -se "select email_address from admin where role ='admin';")
	do
		cat /tmp/webcp/failed_aws | mutt -s "WebCP - AWS Failed" "$EmailAddress"
	done
fi
