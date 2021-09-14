Name=$1
BanTime=$2
IP=$3

Password=`/usr/webcp/get_password.sh`
User=`/usr/webcp/get_username.sh`
DB_HOST=`/usr/webcp/get_db_host.sh`

$(mysql cpadmin -u ${User} -p${Password} -h ${DB_HOST} -se "INSERT INTO fail2ban VALUES (0, '$IP', '', '', '', '*', 0, 'inout', '$(date +\%Y-\%m-\%d\ \%H:\%M:\%S)', $BanTime, '$Name', '$Name', '$Name');")

