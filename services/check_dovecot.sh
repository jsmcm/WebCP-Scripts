#! /bin/bash

Var=`/etc/init.d/dovecot status`

if [[ "$Var" =~ "running" ]]
then
        echo "running..."
else

	Password=`/usr/webcp/get_password.sh`
	EmailAddress=$(mysql cpadmin -u root -p${Password} -se "SELECT email_address FROM admin WHERE deleted = 0 AND username = 'admin';")

        echo "not running"
        /etc/init.d/dovecot restart

	sleep 5
	Var2=`/etc/init.d/dovecot status`

        Var=`date`
        Var="$Var = dovecot was stopped"
        echo $Var >> /usr/webcp/services/dovecot_stopped.txt


	if [[ "$Var2" =~ "running" ]]
	then
		echo "On $Var, dovecot was stopped... I did and automatic restart and dovecot was successfully restarted!" | /usr/bin/mutt -s "DOVECOT RESTARTED!!!!" "$EmailAddress"
	else
		echo "On $Var, dovecot was stopped... I attempted an automatic restart but I could not restart dovecot!" | /usr/bin/mutt -s "DOVECOT STOPPED!!!!" "$EmailAddress"
	fi

	sleep 10
fi


