#!/usr/bin/env bash
Password=`cat /usr/webcp/password`

if [ -f /var/www/html/webcp/fail2ban/tmp/add.working ]
then
	# still busy with previous actions
	exit
fi

echo "Checking add.ban"

if [ -f /var/www/html/webcp/fail2ban/tmp/add.ban ]
then

	mv /var/www/html/webcp/fail2ban/tmp/add.ban /var/www/html/webcp/fail2ban/tmp/add.working
	while read line
	do
		echo "Got $Line"

		IN=$line

		arr=(${IN//,/ })

		x=${arr[0]}
		y=${arr[1]}
	
		echo "x = $x"
		echo "y = $y"

		csf -tr $x
		
		$(mysql cpadmin -u root -p${Password} -se "DELETE FROM csf WHERE ip = '$x';")
		
		csf -td $x $y -d 'inout' 'Manual Ban'

		# echo "INSERT INTO csf VALUES (0, '$x', '', '', '', '*', 0, 'inout', '$(date +\%Y-\%m-\%d\ \%H:\%M:\%S)', $y, 'Manual Ban', 'Manual Ban', 'Manual Ban');" >> /usr/webcp/csf_add.txt

		$(mysql cpadmin -u root -p${Password} -se "INSERT INTO csf VALUES (0, '$x', '', '', '', '*', 0, 'inout', '$(date +\%Y-\%m-\%d\ \%H:\%M:\%S)', $y, 'Manual Ban', 'Manual Ban', 'Manual Ban');")

		URL="http://localhost:10025/fail2ban/update_dns.php?ip=${x}"
		/usr/bin/wget -O /dev/null -o /dev/null -q $URL

	done </var/www/html/webcp/fail2ban/tmp/add.working

	rm -fr /var/www/html/webcp/fail2ban/tmp/add.working
fi
