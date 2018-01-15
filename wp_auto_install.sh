#!/bin/bash           

DomainUsername=$1
DatabaseName=$2
DatabaseUsername=$3
DatabasePassword=$4
FullFileName=$5
Path=$6

#echo "DomainUsername = $DomainUsername" >> /usr/webcp/wp.log
#echo "DatabaseName = $DatabaseName" >> /usr/webcp/wp.log
#echo "DatabaseUsername = $DatabaseUsername" >> /usr/webcp/wp.log
#echo "DatabasePassword = $DatabasePassword" >> /usr/webcp/wp.log
#echo "FullFileName = $FullFileName" >> /usr/webcp/wp.log
#echo "Path = $Path" >> /usr/webcp/wp.log

if [ -z $DomainUsername ]
then
        echo "wp.sh DomainUsername DatabaseName DatabaseUsername DatabasePassword FullFileName Path"
        exit
fi

if [ -z $DatabaseName ]
then
        echo "wp.sh DomainUsername DatabaseName DatabaseUsername DatabasePassword FullFileName Path"
        exit
fi

if [ -z $DatabaseUsername ]
then
        echo "wp.sh DomainUsername DatabaseName DatabaseUsername DatabasePassword FullFileName Path"
        exit
fi

if [ -z $DatabasePassword ]
then
        echo "wp.sh DomainUsername DatabaseName DatabaseUsername DatabasePassword FullFileName Path"
        exit
fi



if [ -z $FullFileName ]
then
        echo "wp.sh DomainUsername DatabaseName DatabaseUsername DatabasePassword FullFileName Path"
        exit 
fi

if [ -z $Path ]
then
        echo "wp.sh DomainUsername DatabaseName DatabaseUsername DatabasePassword FullFileName Path"
        exit 
fi

if [ "${#Path}" -lt "7" ]
then
	echo "Error in wp_auto_install--> Path = '$Path'" >> "/var/log/webcp.log"
	exit
fi

if [ "${#DomainUsername}" -lt "7" ]
then
	echo "Error in wp_auto_install--> DomainUsername = '$DomainUsername'" >> "/var/log/webcp.log"
	exit
fi

echo "pending" > $FullFileName
echo "Path: $Path"
echo "FullFileName: $FullFileName"

rm -fr $Path/WP.zip
rm -fr $Path/index.html

Random1=$RANDOM
Random2=$RANDOM
Random3=$RANDOM
Random4=$RANDOM
Random5=$RANDOM
TempPath="/tmp/$Random1$Random2$Random3$Random4$Random5"
echo "Name: $TempPath";
mkdir $TempPath

cp /var/www/html/webcp/installer/wordpress/WP.zip $TempPath
cd $TempPath
unzip -o ./WP.zip

if [ -d "$TempPath/wordpress" ]
then
	# this is in wordpress dir
	cd $TempPath/wordpress
fi

cp -fr * *.* $Path
rm -fr $TempPath

cd $Path
rm -fr ./wp-config.php

#echo "Reading wp-config-sample"
while read line           
do          
	
	DBName='database_name_here'
	UName='username_here'
	PWD='password_here'

	if [[ "$line" == *"$DBName"* ]]; then
    		echo "define('DB_NAME', '$DatabaseName');" >> wp-config.php      
		#echo "replaced dbname"
	elif [[ "$line" == *"$UName"* ]]; then
    		echo "define('DB_USER', '$DatabaseUsername');" >> wp-config.php      
		#echo "replaced username"
	elif [[ "$line" == *"$PWD"* ]]; then
    		echo "define('DB_PASSWORD', '$DatabasePassword');" >> wp-config.php      
		#echo "Replaced password"
	else
		echo "$line" | sed -e 's///g' >> wp-config.php
		#echo "."
	fi
	 
done <wp-config-sample.php 
#echo "done"


rm -fr $Path/WP.zip

#echo "chmod 755 $Path -R" >> /usr/webcp/wp.log
chmod 755 $Path -R

#echo "chown $DomainUsername.$DomainUsername $Path -R"  >> /usr/webcp/wp.log
chown $DomainUsername.$DomainUsername $Path -R


echo "done" > $FullFileName

