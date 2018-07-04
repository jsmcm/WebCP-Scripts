Name=$1
BanTime=$2
IP=$3

Password=`/usr/webcp/get_password.sh`

$(mysql cpadmin -u root -p${Password} -se "INSERT INTO fail2ban VALUES (0, '$IP', '', '', '', '*', 0, 'inout', '$(date +\%Y-\%m-\%d\ \%H:\%M:\%S)', $BanTime, '$Name', '$Name', '$Name');")

