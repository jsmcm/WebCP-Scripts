Service=$1
IP=$2
BanCount=$3
Action=$4
Password=`cat /usr/webcp/password`

echo "Service: $Service" >> /usr/webcp/f2b.log
echo "IP: $IP" >> /usr/webcp/f2b.log
echo "Action: $Action" >> /usr/webcp/f2b.log
echo "BanCount: $BanCount" >> /usr/webcp/f2b.log
echo "" >> /usr/webcp/f2b.log
echo "=======================================" >> /usr/webcp/f2b.log
echo "" >> /usr/webcp/f2b.log

if [[ "$Action" == "ban" ]]; then
	$(mysql cpadmin -u root -p${Password} -se "INSERT INTO fail2ban VALUES (0, '$Service', '$IP', $BanCount, '', '', '');")
elif [[ "$Action" == "unban" ]]; then
	$(mysql cpadmin -u root -p${Password} -se "DELETE FROM fail2ban;")
fi

