Name=$1
IP=$2

Password=`/usr/webcp/get_password.sh`

$(mysql cpadmin -u root -p${Password} -se "DELETE FROM fail2ban WHERE triggered = '$Name' AND ip = '$IP';")

