#!/bin/bash

DomainName=$1
UserName=$2
redirect=$3
phpVersion=$4
path=$5
primaryDomain=$6
#hsts=$7
hsts="no"
pagespeed=$8
mailSubDomainAdded=0

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
		
echo "	listen 443 ssl http2;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "	listen [::]:443 ssl http2;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf

if [ -f "/etc/nginx/ssl/$DomainName.crt" ] && [ -f "/etc/nginx/ssl/$DomainName.csr" ] && [ -f "/var/www/html/webcp/nm/$DomainName.crtchain" ]
then
	CertChain=`cat /var/www/html/webcp/nm/$DomainName.crtchain`
        echo "  ssl_certificate /etc/nginx/ssl/$DomainName.crt;" >> /etc/nginx/sites-enabled/$DomainName.conf
        echo "  ssl_certificate_key /etc/nginx/ssl/$DomainName.key;" >> /etc/nginx/sites-enabled/$DomainName.conf
        echo "  ssl_trusted_certificate /etc/nginx/ssl/$CertChain;" >> /etc/nginx/sites-enabled/$DomainName.conf

elif [ -f "/etc/letsencrypt/live/$DomainName/cert.pem" ] && [ -f "/etc/letsencrypt/renewal/$DomainName.conf" ]
then
    echo "	ssl_certificate /etc/letsencrypt/live/$DomainName/fullchain.pem;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
    echo "	ssl_certificate_key /etc/letsencrypt/live/$DomainName/privkey.pem;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
    echo "	ssl_trusted_certificate /etc/letsencrypt/live/$DomainName/fullchain.pem;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
fi


echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf

if [ "$hsts" == "enforce" ]
then
	echo "	add_header X-Frame-Options \"SAMEORIGIN\" always;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "	add_header X-XSS-Protection \"1; mode=block\" always;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "	add_header X-Content-Type-Options \"nosniff\" always;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "	add_header Referrer-Policy \"no-referrer-when-downgrade\" always;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "	add_header Content-Security-Policy \"default-src * data: 'unsafe-eval' 'unsafe-inline'\" always;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "	add_header Strict-Transport-Security \"max-age=31536000; includeSubDomains; preload\" always;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
fi

echo "	include /etc/letsencrypt/options-ssl-nginx.conf;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "	ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf

echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf

	if [ "$redirect" == "www" ]
	then
		echo "	server_name $DomainName;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	else
		mailSubDomainAdded=1
		echo "	server_name $DomainName mail.$DomainName;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	fi


echo "	access_log /home/$UserName/home/$UserName/nginx-access.log  main;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "	error_log /home/$UserName/home/$UserName/nginx-error.log  warn;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf

echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "  location ~ /\.well-known/acme-challenge {" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "          return 301 http://$DomainName\$request_uri\$query_string;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "  }" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf

			
if [ "$redirect" == "www" ]
then
	echo "	return 301 https://www.$DomainName\$request_uri\$query_string;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf	
else
	echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
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
	echo "		return 301 https://$DomainName:8443;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "	}" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	
	
	echo "	location /webmail {" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "		return 301 https://$DomainName:2087;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "	}" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	
	echo "	location /phpmyadmin {" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "		return 301 https://$DomainName:2096;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "	}" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	
	
fi			
				
echo "}" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf	

echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf

# www domain
echo "server {" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
			
echo "	listen 443 ssl http2;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "	listen [::]:443 ssl http2;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf


if [ -f "/etc/nginx/ssl/$DomainName.crt" ] && [ -f "/etc/nginx/ssl/$DomainName.csr" ] && [ -f "/var/www/html/webcp/nm/$DomainName.crtchain" ]
then
        CertChain=`cat /var/www/html/webcp/nm/$DomainName.crtchain`
        echo "  ssl_certificate /etc/nginx/ssl/$DomainName.crt;" >> /etc/nginx/sites-enabled/$DomainName.conf
        echo "  ssl_certificate_key /etc/nginx/ssl/$DomainName.key;" >> /etc/nginx/sites-enabled/$DomainName.conf
        echo "  ssl_trusted_certificate /etc/nginx/ssl/$CertChain;" >> /etc/nginx/sites-enabled/$DomainName.conf

elif [ -f "/etc/letsencrypt/live/$DomainName/cert.pem" ] && [ -f "/etc/letsencrypt/renewal/$DomainName.conf" ]
then
    echo "      ssl_certificate /etc/letsencrypt/live/$DomainName/fullchain.pem;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
    echo "      ssl_certificate_key /etc/letsencrypt/live/$DomainName/privkey.pem;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
    echo "      ssl_trusted_certificate /etc/letsencrypt/live/$DomainName/fullchain.pem;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
fi

echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf

if [ "$hsts" == "enforce" ]
then
	echo "	add_header X-Frame-Options \"SAMEORIGIN\" always;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "	add_header X-XSS-Protection \"1; mode=block\" always;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "	add_header X-Content-Type-Options \"nosniff\" always;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "	add_header Referrer-Policy \"no-referrer-when-downgrade\" always;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "	add_header Content-Security-Policy \"default-src * data: 'unsafe-eval' 'unsafe-inline'\" always;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "	add_header Strict-Transport-Security \"max-age=31536000; includeSubDomains; preload\" always;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
fi


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


echo "	include /etc/letsencrypt/options-ssl-nginx.conf;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "	ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf


echo "	access_log /home/$UserName/home/$UserName/nginx-access.log  main;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "	error_log /home/$UserName/home/$UserName/nginx-error.log  warn;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf


echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "  location ~ /\.well-known/acme-challenge {" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "          return 301 http://$DomainName\$request_uri\$query_string;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "  }" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf


if [ "$redirect" == "naked" ]
then
	echo "	return 301 https://$DomainName\$request_uri\$query_string;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf	
else
	echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
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
	echo "		return 301 https://www.$DomainName:8443;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "	}" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	
	
	echo "	location /webmail {" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "		return 301 https://www.$DomainName:2087;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "	}" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	
	echo "	location /phpmyadmin {" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "		return 301 https://www.$DomainName:2096;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "	}" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	
	
fi			
				
echo "}" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf	

echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf

