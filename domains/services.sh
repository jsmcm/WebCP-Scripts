#!/bin/bash
exit

DomainName=$1 
UserName=$2
phpVersion=$3



echo "server {" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        listen 20010;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        listen [::]:20010;" >> /etc/nginx/sites-enabled/$DomainName.conf
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
echo "        listen 20020;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        listen [::]:20020;" >> /etc/nginx/sites-enabled/$DomainName.conf
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
echo "        listen 10030;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        listen [::]:10030;" >> /etc/nginx/sites-enabled/$DomainName.conf
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
echo "        listen 10035;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        listen [::]:10035;" >> /etc/nginx/sites-enabled/$DomainName.conf
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
echo "        listen 10025;" >> /etc/nginx/sites-enabled/$DomainName.conf
echo "        listen [::]:10025;" >> /etc/nginx/sites-enabled/$DomainName.conf
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

