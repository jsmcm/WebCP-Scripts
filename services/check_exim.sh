#! /bin/bash

export DISPLAY=:0.0
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/root/bin
HOME=/root

source $HOME/.profile


Var=`service exim4 status`

echo "$Var"
echo ""

if [[ "$Var" =~ "running" ]]
then
        echo "running..."
else

	Password=`/usr/webcp/get_password.sh`
	User=`/usr/webcp/get_username.sh`
	DB_HOST=`/usr/webcp/get_db_host.sh`


	EmailAddress=$(mysql cpadmin -u ${User} -p${Password} -h ${DB_HOST} -se "SELECT email_address FROM admin WHERE deleted = 0 AND role = 'admin';")

        echo "not running"
        service exim4 restart

	sleep 5
	Var2=`service exim4 status`

        Var=`date`
        Var="$Var = exim4 was stopped"
        echo $Var >> /usr/webcp/services/exim4_stopped.txt


	if [[ "$Var2" =~ "running" ]]
	then
		echo "On $Var, exim4 was stopped... I did and automatic restart and exim4 was successfully restarted!" | /usr/bin/mutt -s "EXIM RESTARTED!!!!" "$EmailAddress"
	else
		echo "On $Var, exim4 was stopped... I attempted an automatic restart but I could not restart exim4!" | /usr/bin/mutt -s "EXIM STOPPED!!!!" "$EmailAddress"
	fi

fi


