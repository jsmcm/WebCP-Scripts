HostName=`hostname`
for FullFileName in /var/www/html/webcp/nm/*.dvh; 
do

	if [ -f $FullFileName ]
	then	
		##echo $FullFileName
		x=$FullFileName
		y=${x%.dvh}
		DomainName=${y##*/}
                echo "file: $DomainName"

		UserName=`cat $FullFileName`

		echo "UserName: $UserName"
		echo "DomainName: $DomainName"

		rm -fr /etc/httpd/conf/vhosts/$DomainName*.conf
		rm -fr /etc/awstats/awstats.${DomainName}.conf
		rm -fr $FullFileName
	fi
done

