#!/bin/bash

UserName=$1
EmailAddress=$2
FileName=$3

echo "1"
if [ "$UserName" == "" ]
then
	echo "Missing arguments!"
	echo "send_email.sh UserName EmailAddress FileName"
	exit
fi

echo "2"
if [ "$EmailAddress" == "" ]
then
	echo "Missing arguments!"
	echo "send_email.sh UserName EmailAddress FileName"
	exit
fi

echo "3"
if [ "$FileName" == "" ]
then
	echo "Missing arguments!"
	echo "send_email.sh UserName EmailAddress FileName"
	exit
fi

echo "Calling mail"
echo "Backup complete for account: $UserName. File Name: $FileName" | mail -s "WebCP - $UserName backup complete" "$EmailAddress"
echo "mail called"
