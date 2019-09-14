#!/bin/bash

DomainName=$1 
UserName=$2
phpVersion=$3
pagespeed=$4


echo "server {" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        listen 2052;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        listen [::]:2052;" >> /etc/nginx/sites-enabled/$DomainName.conf

echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "		#pagespeed $pagespeed;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        server_name $DomainName;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "  return 301 https://$DomainName:2053\$request_uri\$query_string;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "}" >> /etc/nginx/sites-enabled/$DomainName.conf;

echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf

echo "server {" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        listen 2053 ssl http2;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        listen [::]:2053 ssl http2;" >> /etc/nginx/sites-enabled/$DomainName.conf

echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "		#pagespeed $pagespeed;" >> /etc/nginx/sites-enabled/$DomainName.conf


echo "  ssl_certificate /etc/letsencrypt/live/$DomainName/fullchain.pem;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "  ssl_certificate_key /etc/letsencrypt/live/$DomainName/privkey.pem;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "  ssl_trusted_certificate /etc/letsencrypt/live/$DomainName/fullchain.pem;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf

echo "  add_header X-Frame-Options \"SAMEORIGIN\" always;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "  add_header X-XSS-Protection \"1; mode=block\" always;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "  add_header X-Content-Type-Options \"nosniff\" always;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "  add_header Referrer-Policy \"no-referrer-when-downgrade\" always;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "  add_header Content-Security-Policy \"default-src * data: 'unsafe-eval' 'unsafe-inline'\" always;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "add_header Strict-Transport-Security \"max-age=31536000; includeSubDomains; preload\" always;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf

echo "  include /etc/letsencrypt/options-ssl-nginx.conf;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "  ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf


echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        server_name $DomainName;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        root /home/$UserName/.editor;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "	index index.php index.html index.htm;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        location / {" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "                try_files \$uri \$uri/ /index.php?\$args;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        }" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        location ~ \.php\$ {" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "                include snippets/fastcgi-php.conf;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "                fastcgi_pass unix:/run/php/php$phpVersion-fpm-$UserName.sock;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "                fastcgi_send_timeout 300;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "                fastcgi_read_timeout 300;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        }" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        location ~ /\.ht {" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "                deny all;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        }" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        location ~ /\.user.ini {" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "                deny all;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        }" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        location ~ /php.ini {" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "                deny all;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        }" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "}" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf


echo "server {" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        listen 20001;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        listen [::]:20001;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "		#pagespeed $pagespeed;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        server_name $DomainName;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        root /home/$UserName/.passwd;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "	index index.php index.html index.htm;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        location / {" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "                try_files \$uri \$uri/ /index.php?\$args;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        }" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        location ~ \.php\$ {" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "                include snippets/fastcgi-php.conf;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "                fastcgi_pass unix:/run/php/php$phpVersion-fpm-$UserName.sock;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "                fastcgi_send_timeout 300;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "                fastcgi_read_timeout 300;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        }" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        location ~ /\.ht {" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "                deny all;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        }" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        location ~ /\.user.ini {" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "                deny all;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        }" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        location ~ /php.ini {" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "                deny all;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        }" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "}" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf


echo "server {" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        listen 2082;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        listen [::]:2082;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "		#pagespeed $pagespeed;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        server_name $DomainName;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "  return 301 https://$DomainName:2083\$request_uri\$query_string;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "}" >> /etc/nginx/sites-enabled/$DomainName.conf;

echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf

echo "server {" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        listen 2083 ssl http2;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        listen [::]:2083 ssl http2;" >> /etc/nginx/sites-enabled/$DomainName.conf

echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "		#pagespeed $pagespeed;" >> /etc/nginx/sites-enabled/$DomainName.conf

echo "  ssl_certificate /etc/letsencrypt/live/$DomainName/fullchain.pem;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "  ssl_certificate_key /etc/letsencrypt/live/$DomainName/privkey.pem;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "  ssl_trusted_certificate /etc/letsencrypt/live/$DomainName/fullchain.pem;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf

echo "  add_header X-Frame-Options \"SAMEORIGIN\" always;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "  add_header X-XSS-Protection \"1; mode=block\" always;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "  add_header X-Content-Type-Options \"nosniff\" always;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "  add_header Referrer-Policy \"no-referrer-when-downgrade\" always;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "  add_header Content-Security-Policy \"default-src * data: 'unsafe-eval' 'unsafe-inline'\" always;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "add_header Strict-Transport-Security \"max-age=31536000; includeSubDomains; preload\" always;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf

echo "  include /etc/letsencrypt/options-ssl-nginx.conf;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "  ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        server_name $DomainName;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        root /home/$UserName/.cron;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "	index index.php index.html index.htm;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        location / {" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "                try_files \$uri \$uri/ /index.php?\$args;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        }" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        location ~ \.php\$ {" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "                include snippets/fastcgi-php.conf;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "                fastcgi_pass unix:/run/php/php$phpVersion-fpm-$UserName.sock;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "                fastcgi_send_timeout 300;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "                fastcgi_read_timeout 300;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        }" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        location ~ /\.ht {" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "                deny all;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        }" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        location ~ /\.user.ini {" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "                deny all;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        }" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        location ~ /php.ini {" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "                deny all;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        }" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "}" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf


echo "server {" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        listen 2086;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        listen [::]:2086;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "		#pagespeed $pagespeed;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        server_name $DomainName;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "  return 301 https://$DomainName:2087;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "}" >> /etc/nginx/sites-enabled/$DomainName.conf;

echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf

echo "server {" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        listen 2087 ssl http2;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        listen [::]:2087 ssl http2;" >> /etc/nginx/sites-enabled/$DomainName.conf

echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "		#pagespeed $pagespeed;" >> /etc/nginx/sites-enabled/$DomainName.conf

echo "  ssl_certificate /etc/letsencrypt/live/$DomainName/fullchain.pem;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "  ssl_certificate_key /etc/letsencrypt/live/$DomainName/privkey.pem;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "  ssl_trusted_certificate /etc/letsencrypt/live/$DomainName/fullchain.pem;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf

echo "  add_header X-Frame-Options \"SAMEORIGIN\" always;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "  add_header X-XSS-Protection \"1; mode=block\" always;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "  add_header X-Content-Type-Options \"nosniff\" always;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "  add_header Referrer-Policy \"no-referrer-when-downgrade\" always;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "  add_header Content-Security-Policy \"default-src * data: 'unsafe-eval' 'unsafe-inline'\" always;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "add_header Strict-Transport-Security \"max-age=31536000; includeSubDomains; preload\" always;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf

echo "  include /etc/letsencrypt/options-ssl-nginx.conf;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "  ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        server_name $DomainName;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        root /var/www/html/rainloop;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "	index index.php;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        location / {" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "                try_files \$uri \$uri/ /index.php?\$args;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        }" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        location ~ \.php\$ {" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "                include snippets/fastcgi-php.conf;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "                fastcgi_pass unix:/run/php/php$phpVersion-fpm.sock;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "                fastcgi_send_timeout 300;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "                fastcgi_read_timeout 300;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        }" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        location ~ /\.ht {" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "                deny all;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        }" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        location ~ /\.user.ini {" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "                deny all;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        }" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        location ~ /php.ini {" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "                deny all;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        }" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "}" >> /etc/nginx/sites-enabled/$DomainName.conf


echo "server {" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        listen 2095;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        listen [::]:2095;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "		#pagespeed $pagespeed;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        server_name $DomainName;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "  return 301 https://$DomainName:2096;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "}" >> /etc/nginx/sites-enabled/$DomainName.conf;

echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf

echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "server {" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        listen 2096 ssl http2;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        listen [::]:2096 ssl http2;" >> /etc/nginx/sites-enabled/$DomainName.conf

echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "		#pagespeed $pagespeed;" >> /etc/nginx/sites-enabled/$DomainName.conf

echo "  ssl_certificate /etc/letsencrypt/live/$DomainName/fullchain.pem;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "  ssl_certificate_key /etc/letsencrypt/live/$DomainName/privkey.pem;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "  ssl_trusted_certificate /etc/letsencrypt/live/$DomainName/fullchain.pem;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf

echo "  add_header X-Frame-Options \"SAMEORIGIN\" always;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "  add_header X-XSS-Protection \"1; mode=block\" always;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "  add_header X-Content-Type-Options \"nosniff\" always;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "  add_header Referrer-Policy \"no-referrer-when-downgrade\" always;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "  add_header Content-Security-Policy \"default-src * data: 'unsafe-eval' 'unsafe-inline'\" always;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "add_header Strict-Transport-Security \"max-age=31536000; includeSubDomains; preload\" always;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf

echo "  include /etc/letsencrypt/options-ssl-nginx.conf;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "  ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        server_name $DomainName;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        root /var/www/html/phpmyadmin;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "	index index.php;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        location / {" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "                try_files \$uri \$uri/ /index.php?\$args;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        }" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        location ~ \.php\$ {" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "                include snippets/fastcgi-php.conf;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "                fastcgi_pass unix:/run/php/php$phpVersion-fpm.sock;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "                fastcgi_send_timeout 300;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "                fastcgi_read_timeout 300;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        }" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        location ~ /\.ht {" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "                deny all;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        }" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        location ~ /\.user.ini {" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "                deny all;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        }" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        location ~ /php.ini {" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "                deny all;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        }" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "}" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf


			
echo "server {" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        listen 8880;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        listen [::]:8880;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "		#pagespeed $pagespeed;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        server_name $DomainName;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "  return 301 https://$DomainName:8443;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "}" >> /etc/nginx/sites-enabled/$DomainName.conf;

echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf

	 
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "server {" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        listen 8443 ssl http2;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        listen [::]:8443 ssl http2;" >> /etc/nginx/sites-enabled/$DomainName.conf

echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "		#pagespeed $pagespeed;" >> /etc/nginx/sites-enabled/$DomainName.conf

echo "  ssl_certificate /etc/letsencrypt/live/$DomainName/fullchain.pem;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "  ssl_certificate_key /etc/letsencrypt/live/$DomainName/privkey.pem;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "  ssl_trusted_certificate /etc/letsencrypt/live/$DomainName/fullchain.pem;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf

echo "  add_header X-Frame-Options \"SAMEORIGIN\" always;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "  add_header X-XSS-Protection \"1; mode=block\" always;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "  add_header X-Content-Type-Options \"nosniff\" always;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "  add_header Referrer-Policy \"no-referrer-when-downgrade\" always;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "  add_header Content-Security-Policy \"default-src * data: 'unsafe-eval' 'unsafe-inline'\" always;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "add_header Strict-Transport-Security \"max-age=31536000; includeSubDomains; preload\" always;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf

echo "  include /etc/letsencrypt/options-ssl-nginx.conf;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "  ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        server_name $DomainName;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        root /var/www/html/webcp;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "	index index.php;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        location / {" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "                try_files \$uri \$uri/ /index.php?\$args;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        }" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        location ~ \.php\$ {" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "                include snippets/fastcgi-php.conf;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "                fastcgi_pass unix:/run/php/php$phpVersion-fpm.sock;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "                fastcgi_send_timeout 300;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "                fastcgi_read_timeout 300;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        }" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        location ~ /\.ht {" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "                deny all;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        }" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        location ~ /\.user.ini {" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "                deny all;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        }" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        location ~ /php.ini {" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "                deny all;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        }" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "}" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf

