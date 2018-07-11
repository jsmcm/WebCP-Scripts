#!/bin/bash

x=$(pgrep suspension.sh | wc -w)
if [ $x -gt 2 ]; then
        exit
fi

Reload=0
Password=`/usr/webcp/get_password.sh`

mkdir -p /etc/nginx/sites-suspended
mkdir -p /var/www/html/suspended

SuspendedFileExists=0

if [ -f /var/www/html/suspended/index.html ]
then
	SuspendedFileExists=1
fi


if [ -f /var/www/html/suspended/index.htm ]
then
	SuspendedFileExists=1
fi


if [ -f /var/www/html/suspended/index.php ]
then
	SuspendedFileExists=1
fi

if [ $SuspendedFileExists == 0 ]
then
echo "<html>" > /var/www/html/suspended/index.html
echo "<head>" >> /var/www/html/suspended/index.html
echo "<title>Web Hosting Account Suspended</title>" >> /var/www/html/suspended/index.html
echo "</head>" >> /var/www/html/suspended/index.html
echo "<body style=\"margin: 0px;color: white;\">" >> /var/www/html/suspended/index.html
echo "<table width=\"100%\" height=\"100%\" cellpadding=\"0\" cellspacing=\"0\">" >> /var/www/html/suspended/index.html
echo "<tr>" >> /var/www/html/suspended/index.html
echo "<td align=\"center\" valign=\"top\" bgcolor=\"#630a01\">" >> /var/www/html/suspended/index.html
echo "<p style=\"font-size:48px; font-weight: bold;\">Site suspended<p style=\"font-size:22px;\">" >> /var/www/html/suspended/index.html
echo "This domain has been suspended. Please contact support to reenable it." >> /var/www/html/suspended/index.html
echo "</p>" >> /var/www/html/suspended/index.html
echo "</td>" >> /var/www/html/suspended/index.html
echo "</tr>" >> /var/www/html/suspended/index.html
echo "</table>" >> /var/www/html/suspended/index.html
echo "</body>" >> /var/www/html/suspended/index.html
echo "</html>" >> /var/www/html/suspended/index.html


fi







for FullFileName in /var/www/html/webcp/nm/*.suspend; 
do

	if [ -f $FullFileName ]
	then	
		echo $FullFileName
		x=$FullFileName
                echo "x: '$x'"
		y=${x%.suspend}
                echo "y: '$y'"
		UserName=${y##*/}

		DomainName=$(mysql cpadmin -u root -p${Password} -se "SELECT fqdn FROM domains WHERE deleted = 0 AND UserName = '$UserName' AND domain_type = 'primary';")


		if [ "${#DomainName}" -gt "3" ]
		then
			Reload=1
			if [ -f "/etc/nginx/sites-enabled/$DomainName.conf" ]
			then
				mv /etc/nginx/sites-enabled/$DomainName.conf /etc/nginx/sites-suspended/$DomainName.conf
			fi

			echo "server {" > /etc/nginx/sites-enabled/$DomainName.conf
			echo "listen 443;" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "server_name $DomainName;" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "return 301 http://$DomainName;" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "}" >> /etc/nginx/sites-enabled/$DomainName.conf


			echo "server {" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "listen 80;" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "server_name $DomainName;" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "root /var/www/html/suspended;" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "location / {" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "rewrite ^ /index.html break;" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "}" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "" >> /etc/nginx/sites-enabled/$DomainName.conf
			echo "}" >> /etc/nginx/sites-enabled/$DomainName.conf
	
			rm -fr $FullFileName
		fi
	fi

done


for FullFileName in /var/www/html/webcp/nm/*.unsuspend; 
do

	if [ -f $FullFileName ]
	then	
		echo $FullFileName
		x=$FullFileName
                echo "x: '$x'"
		y=${x%.unsuspend}
                echo "y: '$y'"
		UserName=${y##*/}

		DomainName=$(mysql cpadmin -u root -p${Password} -se "SELECT fqdn FROM domains WHERE deleted = 0 AND UserName = '$UserName' AND domain_type = 'primary';")

		
	
			if [ -f "/etc/nginx/sites-suspended/$DomainName.conf" ]
			then
				Reload=1
				rm -fr /etc/nginx/sites-enabled/$DomainName.conf

				mv /etc/nginx/sites-suspended/$DomainName.conf /etc/nginx/sites-enabled/$DomainName.conf
			fi
	
	
			rm -fr $FullFileName
	fi

done

if [ $Reload == 1 ] 
then
	service nginx reload
fi


echo "Done"
