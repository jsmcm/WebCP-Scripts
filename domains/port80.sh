#!/bin/bash

DomainName=$1
UserName=$2
redirect=$3
phpVersion=$4
path=$5
primaryDomain=$6
pagespeed=$7
webp=$8
useCache=$9
publicPath=${10}
accessControlAllowOrigin=${11}
accessControlAllowMethods=${12}
accessControlAllowHeaders=${13}
accessControlExposeHeaders=${14}


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

domainPath="/home/$UserName/home/$UserName/$publicPath"
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
echo "#redirect == $redirect" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
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

echo "	root $domainPath;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf

if [ "$accessControlAllowOrigin" != "" ]
then
        echo "    add_header 'Access-Control-Allow-Origin' '$accessControlAllowOrigin';" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
fi


if [ "$accessControlAllowMethods" != "" ]
then
        echo "    add_header 'Access-Control-Allow-Methods' '$accessControlAllowMethods';" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
fi



if [ "$accessControlAllowHeaders" != "" ]
then
        echo "    add_header 'Access-Control-Allow-Headers' '$accessControlAllowHeaders';" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
fi

if [ "$accessControlExposeHeaders" != "" ]
then
        echo "    add_header 'Access-Control-Expose-Headers' '$accessControlExposeHeaders';" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
fi




echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "  location ~ /\.well-known/acme-challenge {" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "          try_files \$uri \$uri/ /index.php?\$args;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "  }" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf



if [ "$redirect" == "www" ]
then
	echo "	return 301 http://www.$DomainName\$request_uri\$query_string;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf	
else

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


if [ "$webp" == "auto" ]
then
	echo "	location ~* ^(/.+)\.(jpg|jpeg|jpe|png)\$ {" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "		add_header Vary Accept;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "		expires 365d;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "		access_log off;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "		add_header Pragma public;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "		add_header Cache-Control \"public\";" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "	if (\$http_accept !~* \"webp\"){" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "		break;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "	}" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "	try_files" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "		\$uri.webp" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "		@redirect" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "	;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "}" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "	location ~* ^(/.+)\.(jpg|jpeg|jpe|png)\.webp\$ {" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "		expires 365d;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "		access_log off;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "		add_header Pragma public;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "		add_header Cache-Control \"public\";" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "	try_files" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "		\$uri" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "		@redirect" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "	;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "	}" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "	location @redirect {" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "		proxy_pass http://127.0.0.1:8880/webp-on-demand.php?xsource=\$request_filename&xuser=$UserName;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "	}" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
fi

	echo "	location ~* ^.+\.(ogg|ogv|svg|svgz|eot|otf|woff|mp4|ttf|rss|atom|jpg|jpeg|gif|png|ico|zip|tgz|gz|rar|bz2|doc|xls|exe|ppt|tar|mid|midi|wav|bmp|rtf|css|js)\$ {" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "		expires 365d;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "		access_log off;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "		add_header Pragma public;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "		add_header Cache-Control \"public\";" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "	}" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
        echo "	location / {" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
        echo "		try_files \$uri \$uri/ /index.php?\$args;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
        echo "	}" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf




	if [ "$useCache" == "true" ]
	then
		echo "          #https://www.linuxbabe.com/nginx/setup-nginx-fastcgi-cache" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
		echo "          set \$skip_cache 0;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
		echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
		echo "          # POST requests and urls with a query string should always go to PHP" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
		echo "          if (\$request_method = POST) {" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
		echo "              set \$skip_cache 1;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
		echo "          }" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
		echo "          if (\$query_string != \"\") {" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
		echo "              set \$skip_cache 1;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
		echo "          }" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
		echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
		echo "          # Don't cache uris containing the following segments" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
		echo "          if (\$request_uri ~* \"/wp-admin/|/xmlrpc.php|wp-.*.php|^/feed/*|/tag/.*/feed/*|index.php|/.*sitemap.*\.(xml|xsl)\") {" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
		echo "              set \$skip_cache 1;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
		echo "          }" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
		echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
		echo "          # Don't use the cache for logged in users or recent commenters" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
		echo "          if (\$http_cookie ~* \"comment_author|wordpress_[a-f0-9]+|wp-postpass|wordpress_no_cache|wordpress_logged_in\") {" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
		echo "              set \$skip_cache 1;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
		echo "          }" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
		echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
		echo "          if (\$remote_addr ~* \"12.34.56.78|12.34.56.79\") {" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
		echo "               set \$skip_cache 1;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
		echo "          }" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	fi





        echo "	location ~ \.php\$ {" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "		include snippets/fastcgi-php.conf;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf

        if [ "$useCache" == "true" ]
        then
		echo "		fastcgi_cache_bypass \$skip_cache;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
        	echo "          fastcgi_no_cache \$skip_cache;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
        	echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
        	echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
        	echo "          fastcgi_cache phpcache;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
        	echo "          fastcgi_cache_valid 200 301 302 60m;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
        	echo "          fastcgi_cache_use_stale error timeout updating invalid_header http_500 http_503;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
        	echo "          fastcgi_cache_min_uses 1;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
        	echo "          fastcgi_cache_lock on;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
        	echo "          add_header X-FastCGI-Cache \$upstream_cache_status;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	fi

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
	
echo "	root $domainPath;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf

if [ "$accessControlAllowOrigin" != "" ]
then
        echo "    add_header 'Access-Control-Allow-Origin' '$accessControlAllowOrigin';" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
fi


if [ "$accessControlAllowMethods" != "" ]
then
        echo "    add_header 'Access-Control-Allow-Methods' '$accessControlAllowMethods';" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
fi



if [ "$accessControlAllowHeaders" != "" ]
then
        echo "    add_header 'Access-Control-Allow-Headers' '$accessControlAllowHeaders';" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
fi

if [ "$accessControlExposeHeaders" != "" ]
then
        echo "    add_header 'Access-Control-Expose-Headers' '$accessControlExposeHeaders';" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
fi




echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "  location ~ /\.well-known/acme-challenge {" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "          try_files \$uri \$uri/ /index.php?\$args;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "  }" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf

		        
if [ "$redirect" == "naked" ]
then
	echo "	return 301 http://$DomainName\$request_uri\$query_string;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf	
else
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



if [ "$webp" == "auto" ]
then
	echo "	location ~* ^(/.+)\.(jpg|jpeg|jpe|png)\$ {" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "		add_header Vary Accept;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "		expires 365d;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "		access_log off;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "		add_header Pragma public;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "		add_header Cache-Control \"public\";" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "	if (\$http_accept !~* \"webp\"){" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "		break;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "	}" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "	try_files" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "		\$uri.webp" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "		@redirect" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "	;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "}" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "	location ~* ^(/.+)\.(jpg|jpeg|jpe|png)\.webp\$ {" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "		expires 365d;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "		access_log off;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "		add_header Pragma public;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "		add_header Cache-Control \"public\";" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "	try_files" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "		\$uri" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "		@redirect" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "	;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "	}" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "	location @redirect {" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "		proxy_pass http://127.0.0.1:8880/webp-on-demand.php?xsource=\$request_filename&xuser=$UserName;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "	}" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
fi



	echo "	location ~* ^.+\.(ogg|ogv|svg|svgz|eot|otf|woff|mp4|ttf|rss|atom|jpg|jpeg|gif|png|ico|zip|tgz|gz|rar|bz2|doc|xls|exe|ppt|tar|mid|midi|wav|bmp|rtf|css|js)\$ {" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "		expires 365d;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "		access_log off;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "		add_header Pragma public;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "		add_header Cache-Control \"public\";" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "	}" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "	location / {" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "		try_files \$uri \$uri/ /index.php?\$args;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "	}" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf



	if [ "$useCache" == "true" ]
	then
		echo "          #https://www.linuxbabe.com/nginx/setup-nginx-fastcgi-cache" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
		echo "          set \$skip_cache 0;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
		echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
		echo "          # POST requests and urls with a query string should always go to PHP" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
		echo "          if (\$request_method = POST) {" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
		echo "              set \$skip_cache 1;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
		echo "          }" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
		echo "          if (\$query_string != \"\") {" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
		echo "              set \$skip_cache 1;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
		echo "          }" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
		echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
		echo "          # Don't cache uris containing the following segments" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
		echo "          if (\$request_uri ~* \"/wp-admin/|/xmlrpc.php|wp-.*.php|^/feed/*|/tag/.*/feed/*|index.php|/.*sitemap.*\.(xml|xsl)\") {" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
		echo "              set \$skip_cache 1;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
		echo "          }" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
		echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
		echo "          # Don't use the cache for logged in users or recent commenters" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
		echo "          if (\$http_cookie ~* \"comment_author|wordpress_[a-f0-9]+|wp-postpass|wordpress_no_cache|wordpress_logged_in\") {" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
		echo "              set \$skip_cache 1;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
		echo "          }" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
		echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
		echo "          if (\$remote_addr ~* \"12.34.56.78|12.34.56.79\") {" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
		echo "               set \$skip_cache 1;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
		echo "          }" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	fi



	echo "	location ~ \.php\$ {" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "		include snippets/fastcgi-php.conf;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf

	if [ "$useCache" == "true" ]
	then
		echo "		fastcgi_cache_bypass \$skip_cache;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
        	echo "          fastcgi_no_cache \$skip_cache;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
        	echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
        	echo "" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
        	echo "          fastcgi_cache phpcache;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
        	echo "          fastcgi_cache_valid 200 301 302 60m;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
        	echo "          fastcgi_cache_use_stale error timeout updating invalid_header http_500 http_503;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
        	echo "          fastcgi_cache_min_uses 1;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
        	echo "          fastcgi_cache_lock on;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
        	echo "          add_header X-FastCGI-Cache \$upstream_cache_status;" >> /etc/nginx/sites-enabled/$nginxConfigDomain.conf
	fi


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

