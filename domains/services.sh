#!/bin/bash

DomainName=$1 
UserName=$2
phpVersion=$3
pagespeed=$4


echo "server {" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        listen 2052;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        listen [::]:2052;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "		pagespeed $pagespeed;" >> /etc/nginx/sites-enabled/$DomainName.conf
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
echo "}" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf


echo "server {" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        listen 20001;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        listen [::]:20001;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "		pagespeed $pagespeed;" >> /etc/nginx/sites-enabled/$DomainName.conf
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
echo "}" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf


echo "server {" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        listen 2082;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        listen [::]:2082;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "		pagespeed $pagespeed;" >> /etc/nginx/sites-enabled/$DomainName.conf
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
echo "}" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf


echo "server {" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        listen 2086;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        listen [::]:2086;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "		pagespeed $pagespeed;" >> /etc/nginx/sites-enabled/$DomainName.conf
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
echo "}" >> /etc/nginx/sites-enabled/$DomainName.conf


echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "server {" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        listen 2095;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        listen [::]:2095;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "		pagespeed $pagespeed;" >> /etc/nginx/sites-enabled/$DomainName.conf
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
echo "}" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf


			
	 
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "server {" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        listen 8880;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        listen [::]:8880;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "		pagespeed $pagespeed;" >> /etc/nginx/sites-enabled/$DomainName.conf
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
echo "}" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "" >> /etc/nginx/sites-enabled/$DomainName.conf

