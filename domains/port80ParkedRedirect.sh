#!/bin/bash

#$parkedDomainName $UserName "naked" $phpVersion $path $parentDomainName

DomainName=$1
DomainUserName=$2
redirect=$3
phpVersion=$4
path=$5
primaryDomain=$6
pagespeed=$7

nginxConfigDomain=$DomainName
if [ "$primaryDomain" != "" ]
then
        nginxConfigDomain=$primaryDomain
fi
echo "nginxConfigDomain = $nginxConfigDomain"

domainPath="/home/$UserName/home/$UserName/public_html"
if [ "$path" != "" ]
then
        domainPath=$path
fi
echo "domainPath = $domainPath";

	
#naked domain
echo "server {" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "	listen 80;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "	listen [::]:80;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "	server_name $DomainName;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf

echo "#pagespeed $pagespeed;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf

echo "	access_log /home/$DomainUserName/home/nginx-access.log  main;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "	error_log /home/$DomainUserName/home/nginx-error.log  warn;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf

echo "	location /webcp {" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "		return 301 http://$DomainName:8880;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "	}" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf

echo "        location /webmail {" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "                return 301 http://$DomainName:2086;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "        }" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf

echo "        location /phpmyadmin {" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "                return 301 http://$DomainName:2095;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "        }" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	
echo "        location / {" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	
if [ "$redirect" == "www" ]
then
    	echo "		return 301 http://www.$primaryDomain\$request_uri\$query_string;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
else
    	echo "		return 301 http://$primaryDomain\$request_uri\$query_string;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
fi

echo "        }" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf

echo "}" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf

echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf



# www domain
echo "server {" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "	listen 80;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "	listen [::]:80;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "	server_name www.$DomainName;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf

echo "#pagespeed $pagespeed;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	
echo "	access_log /home/$DomainUserName/home/nginx-access.log  main;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "	error_log /home/$DomainUserName/home/nginx-error.log  warn;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf

echo "	location /webcp {" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "		return 301 http://www.$DomainName:8880;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "	}" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf

echo "	location /webmail {" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "		return 301 http://www.$DomainName:2086;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "	}" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf

echo "	location /phpmyadmin {" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "		return 301 http://www.$DomainName:2095;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "	}" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	
echo "	location / {" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	
if [ "$redirect" == "naked" ]
then
    	echo "		return 301 http://$primaryDomain\$request_uri\$query_string;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
else
    	echo "		return 301 http://www.$primaryDomain\$request_uri\$query_string;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
fi

echo "	}" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf

echo "}" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf


echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
