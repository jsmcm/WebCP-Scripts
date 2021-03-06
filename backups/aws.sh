#!/bin/bash

RemotePath=$1
Type=$2
Count=$3

Failed=0

if [ ! -f "/usr/local/bin/aws" ]
then
	#install aws cli
	/usr/webcp/backups/aws_install.sh
fi

echo "The following AWS files failed to transfer: " > /tmp/webcp/failed_aws
echo "" >> /tmp/webcp/failed_aws
discard=`/usr/local/bin/aws s3 mb s3://$RemotePath`

for FullFileName in /var/www/html/backups/$Type/*.tar.gz
do
        if [ -f $FullFileName ]
        then

		#Result=`/usr/webcp/backups/aws_ins.sh "$FullFileName" "$RemotePath" "$Type" "$Count" |  cut -d$'\r' -f 2 | cut -c1-6`
		completeResult=`/usr/webcp/backups/aws_ins.sh "$FullFileName" "$RemotePath" "$Type" "$Count"`

		Result=`echo "$completeResult" | cut -d$'\r' -f 2 | cut -c1-9`


		AWSResult=0

		if [[ $Result == "Completed" ]]
		then
			AWSResult=1
		fi

		if [ $AWSResult == 0 ]
		then
			Failed=1
			echo "FAILED: $FullFileName" >> /tmp/webcp/failed_aws
			echo -e "completeResult: $completeResult" >> /tmp/webcp/failed_aws
			echo "completeResult: $completeResult" >> /tmp/webcp/failed_aws
			echo -e "completeResult: ${completeResult/\\n/\\r\\n}" >> /tmp/webcp/failed_aws
			echo "completeResult: ${completeResult/\\n/\\r\\n}" >> /tmp/webcp/failed_aws

		fi
	fi

done

if [ $Failed == 1 ]
then

	Password=`/usr/webcp/get_password.sh`	
	User=`/usr/webcp/get_username.sh`
	DB_HOST=`/usr/webcp/get_db_host.sh`

	for EmailAddress in $(mysql cpadmin -u ${User} -p${Password} -h ${DB_HOST} -se "select email_address from admin where role ='admin';")
	do
		cat /tmp/webcp/failed_aws | mutt -s "WebCP - AWS Failed" "$EmailAddress"
	done
fi
