#!/bin/bash

DomainName=$1
UserName=$2
redirect=$3
phpVersion=$4
path=$5
primaryDomain=$6
pagespeed=$7

mailSubDomainAdded=0

echo "In port80.sh DomainName: $DomainName"
echo "In port80.sh UserName: $UserName"
echo "In port80.sh redirect: $redirect"
echo "In port80.sh phpVersion: $phpVersion"
echo "In port80.sh path: $path"
echo "In port80.sh primaryDomain: $primaryDomain"

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

# naked domain
echo "server {" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
		
echo "	listen 80;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "	listen [::]:80;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "	" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf

if [ "$redirect" == "www" ]
then
	echo "	server_name $DomainName;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
else
	echo "	server_name $DomainName mail.$DomainName;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	mailSubDomainAdded=1
fi

echo "#pagespeed $pagespeed;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf

echo "	access_log /home/$UserName/home/$UserName/nginx-access.log  main;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "	error_log /home/$UserName/home/$UserName/nginx-error.log  warn;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf


echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "  location ~ /\.well-known/acme-challenge {" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "          try_files \$uri \$uri/ /index.php?\$args;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "  }" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf



if [ "$redirect" == "www" ]
then
	echo "	return 301 http://www.$DomainName\$request_uri\$query_string;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf	
else

	echo "	root $domainPath;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
        echo "	index index.php index.html index.htm;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
        echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf




        echo "  location ~ /\.user\.ini$ {" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
        echo "          deny all;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
        echo "  }" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
        echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf

        echo "  location ~ /*\.ini$ {" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
        echo "          deny all;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
        echo "  }" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
        echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf





	echo "	location ~* ^.+\.(ogg|ogv|svg|svgz|eot|otf|woff|mp4|ttf|rss|atom|jpg|jpeg|gif|png|ico|zip|tgz|gz|rar|bz2|doc|xls|exe|ppt|tar|mid|midi|wav|bmp|rtf|css|js)\$ {" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "		expires 30d;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "		access_log off;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "		add_header Pragma public;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "		add_header Cache-Control \"public\";" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "	}" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
        echo "	location / {" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
        echo "		try_files \$uri \$uri/ /index.php?\$args;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
        echo "	}" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
        echo "	location ~ \.php\$ {" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "		include snippets/fastcgi-php.conf;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "		fastcgi_pass unix:/run/php/php$phpVersion-fpm-$UserName.sock;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "		fastcgi_send_timeout 300;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "		fastcgi_read_timeout 300;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "	}" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "	location ~ /\.ht {" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "		deny all;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "	}" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	
	echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	
	echo "	location /webcp {" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "		return 301 http://$DomainName:8880;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "	}" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	
	echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	
	echo "	location /webmail {" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "		return 301 http://$DomainName:2086;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "	}" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	
	echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	
	echo "	location /phpmyadmin {" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "		return 301 http://$DomainName:2095;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "	}" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	
	
fi			
				
echo "}" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf	

echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf

# www domain
echo "server {" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
			
echo "	listen 80;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "	listen [::]:80;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "	" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf

if [ "$redirect" == "naked" ]
then
	echo "	server_name www.$DomainName;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
else

	if [ $mailSubDomainAdded == 0 ] 
	then
		echo "	server_name www.$DomainName mail.$DomainName;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	else
		echo "	server_name www.$DomainName;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	fi	
fi
	
	echo "#pagespeed $pagespeed;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf

echo "	access_log /home/$UserName/home/$UserName/nginx-access.log  main;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "	error_log /home/$UserName/home/$UserName/nginx-error.log  warn;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf

echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf

echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "  location ~ /\.well-known/acme-challenge {" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "          try_files \$uri \$uri/ /index.php?\$args;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "  }" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf

		        
if [ "$redirect" == "naked" ]
then
	echo "	return 301 http://$DomainName\$request_uri\$query_string;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf	
else
	echo "	root $domainPath;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "	index index.php index.html index.htm;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf



        echo "  location ~ /\.user\.ini$ {" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
        echo "          deny all;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
        echo "  }" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
        echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf

        echo "  location ~ /*\.ini$ {" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
        echo "          deny all;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
        echo "  }" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
        echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf





	echo "	location ~* ^.+\.(ogg|ogv|svg|svgz|eot|otf|woff|mp4|ttf|rss|atom|jpg|jpeg|gif|png|ico|zip|tgz|gz|rar|bz2|doc|xls|exe|ppt|tar|mid|midi|wav|bmp|rtf|css|js)\$ {" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "		expires 30d;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "		access_log off;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "		add_header Pragma public;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "		add_header Cache-Control \"public\";" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "	}" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "	location / {" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "		try_files \$uri \$uri/ /index.php?\$args;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "	}" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "	location ~ \.php\$ {" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "		include snippets/fastcgi-php.conf;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "		fastcgi_pass unix:/run/php/php$phpVersion-fpm-$UserName.sock;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "		fastcgi_send_timeout 300;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "		fastcgi_read_timeout 300;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "	}" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "	location ~ /\.ht {" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "		deny all;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "	}" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
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
	
	
fi			
				
echo "}" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf	

echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf

