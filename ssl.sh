#!/bin/bash


x=$(pgrep ssl.sh | wc -w)
if [ $x -gt 2 ]; then
        exit
fi

if [ ! -d "/etc/nginx/ssl/" ]
then
	mkdir /etc/nginx/ssl/ -p
fi

for FullFileName in /var/www/html/webcp/nm/*.ssl;
do
	if [ -f "$FullFileName" ]
	then

	HostName=$(basename "$FullFileName")
	HostName=${HostName%.*}
	#echo "FullFileName: $FullFileName"
	#echo "HostName: $HostName"

	while read line
	do
		#echo "Line: $line"

	     	if [ ! -z "$line" ]
	        then
	
	            	if [[ "$line" == *"CountryCode"* ]]; then
	                         CountryCode=$line
	                         CountryCode=${CountryCode##*CountryCode=}
	
	                elif [[ "$line" == *"Province"* ]]; then
	                         Province=$line
	                         Province=${Province##*Province=}
	
	                elif [[ "$line" == *"Town"* ]]; then
	                         Town=$line
	                         Town=${Town##*Town=}
	
	                elif [[ "$line" == *"CompanyName"* ]]; then
	                        CompanyName=$line
	                        CompanyName=${CompanyName##*CompanyName=}
	
	                elif [[ "$line" == *"Division"* ]]; then
	                        Division=$line
	                  	Division=${Division##*Division=}
	
	        	elif [[ "$line" == *"EmailAddress"* ]]; then
	                	EmailAddress=$line
				EmailAddress=${EmailAddress##*EmailAddress=}
	
		fi
	fi
	
	done <$FullFileName
	
	if [ -z "$CountryCode" ] 
	then
		echo "usage: ssl.sh COUNTRY_CODE PROVINCE TOWN COMPANY_NAME DIVISION EMAIL_ADDRESS; FILE NAME: hostname.ssl"
		rm -fr $FullFileName
		exit
	fi
	
	if [ -z "$Province" ] 
	then
		echo "usage: ssl.sh COUNTRY_CODE PROVINCE TOWN COMPANY_NAME DIVISION EMAIL_ADDRESS; FILE NAME: hostname.ssl"
		rm -fr $FullFileName
		exit
	fi
	
	if [ -z "$Town" ] 
	then
		echo "usage: ssl.sh COUNTRY_CODE PROVINCE TOWN COMPANY_NAME DIVISION EMAIL_ADDRESS; FILE NAME: hostname.ssl"
		rm -fr $FullFileName
		exit
	fi
	
	if [ -z "$CompanyName" ] 
	then
		echo "usage: ssl.sh COUNTRY_CODE PROVINCE TOWN COMPANY_NAME DIVISION EMAIL_ADDRESS; FILE NAME: hostname.ssl"
		rm -fr $FullFileName
		exit
	fi
	
	if [ -z "$Division" ] 
	then
		echo "usage: ssl.sh COUNTRY_CODE PROVINCE TOWN COMPANY_NAME DIVISION EMAIL_ADDRESS; FILE NAME: hostname.ssl"
		rm -fr $FullFileName
		exit
	fi
	
	if [ -z "$EmailAddress" ] 
	then
		echo "usage: ssl.sh COUNTRY_CODE PROVINCE TOWN COMPANY_NAME DIVISION EMAIL_ADDRESS; FILE NAME: hostname.ssl"
		rm -fr $FullFileName
		exit
	fi
	
	
	if [ -z "$HostName" ] 
	then
		echo "usage: ssl.sh COUNTRY_CODE PROVINCE TOWN COMPANY_NAME DIVISION EMAIL_ADDRESS; FILE NAME: hostname.ssl"
		rm -fr $FullFileName
		exit
	fi
		
	if [ -f "/etc/nginx/ssl/$HostName.csr" ]
	then
		rm -fr /etc/nginx/ssl/$HostName.csr
	fi
	
	if [ -f "/etc/nginx/ssl/$HostName.crt" ]
	then
		rm -fr /etc/nginx/ssl/$HostName.crt
	fi
	
	if [ -f "/etc/nginx/ssl/$HostName.key" ]
	then
		rm -fr /etc/nginx/ssl/$HostName.key
	fi
	
	echo ""
	echo "CountryCode: $CountryCode"
	echo "Province: $Province"
	echo "Town: $Town"
	echo "CompanyName: $CompanyName"
	echo "Division: $Division"
	echo "HostName: $HostName"
	echo "EmailAddress: $EmailAddress"
	echo ""

	/usr/webcp/ssl.exp "$CountryCode" "$Province" "$Town" "$CompanyName" "$Division" "$HostName" "$EmailAddress"

	rm -fr $FullFileName
	fi
done

/usr/webcp/email/make_dovecot_ssl.sh

