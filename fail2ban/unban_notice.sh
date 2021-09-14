Name=$1
IP=$2

Password=`/usr/webcp/get_password.sh`
User=`/usr/webcp/get_username.sh`
DB_HOST=`/usr/webcp/get_db_host.sh`

$(mysql cpadmin -u ${User} -p${Password} -h ${DB_HOST} -se "DELETE FROM fail2ban WHERE triggered = '$Name' AND ip = '$IP';")


