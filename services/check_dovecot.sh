#! /bin/bash

export DISPLAY=:0.0
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/root/bin
HOME=/root

source $HOME/.profile

Var=`service dovecot status`

if [[ "$Var" =~ "running" ]]
then
        echo "running..."
else

	Password=`/usr/webcp/get_password.sh`
	User=`/usr/webcp/get_username.sh`
	DB_HOST=`/usr/webcp/get_db_host.sh`
	
	EmailAddress=$(mysql cpadmin -u ${User} -p${Password} -h ${DB_HOST} -se "SELECT email_address FROM admin WHERE deleted = 0 AND role = 'admin';")

        echo "not running"
        service dovecot restart

	sleep 5
	Var2=`service dovecot status`

        echo $Var >> /usr/webcp/services/dovecot_stopped.txt
        Var=`date`
        Var="$Var = dovecot was stopped"
        echo $Var >> /usr/webcp/services/dovecot_stopped.txt


	if [[ "$Var2" =~ "running" ]]
	then
		echo "On $Var, dovecot was stopped... I did and automatic restart and dovecot was successfully restarted!" | /usr/bin/mutt -s "DOVECOT RESTARTED!!!!" "$EmailAddress"
	else
		echo "On $Var, dovecot was stopped... I attempted an automatic restart but I could not restart dovecot!" | /usr/bin/mutt -s "DOVECOT STOPPED!!!!" "$EmailAddress"
	fi
fi


