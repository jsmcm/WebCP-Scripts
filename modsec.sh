#!/bin/sh

ifStart=`date '+%d'`


if [ ! -f "/etc/httpd/conf.d/modsec/modsecurity_crs_41_xss_attacks.conf" ]
then
        #echo "File does not exist"
        ifStart=24
fi

if [ $ifStart == 24 ]
then

	TempFile="modsec_update_"
	TempFile="$TempFile`date '+%Y%m%d'`"
	
	if [ -f "/var/www/html/webcp/tmp/$TempFile" ]
	then
		exit
	fi

	touch "/var/www/html/webcp/tmp/$TempFile"


	if [ ! -d "/tmp/modsec" ]
	then
		mkdir /tmp/modsec
	fi

	cd /tmp/modsec
	rm -fr /tmp/modsec/*

	wget https://codeload.github.com/SpiderLabs/owasp-modsecurity-crs/legacy.zip/master -O /tmp/modsec/master.zip
		
	if [ -f "/tmp/modsec/master.zip" ] 
	then
		unzip /tmp/modsec/master.zip		
		for FullFileName in /tmp/modsec/*;
		do			
			if [ -d "$FullFileName" ]
			then 
				cd $FullFileName
				if [ -d "$FullFileName/base_rules/" ]
				then
					cd $FullFileName/base_rules/
					mv * /etc/httpd/conf.d/modsec -f
					/etc/init.d/httpd graceful
					exit
				fi
			fi
		done

	fi
fi

