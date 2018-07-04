#! /bin/bash

Var=`/etc/init.d/clamd status`

if [[ "$Var" =~ "running" ]]
then
        echo "running..."
else

	Password=`/usr/webcp/get_password.sh`
	EmailAddress=$(mysql cpadmin -u root -p${Password} -se "SELECT email_address FROM admin WHERE deleted = 0 AND username = 'admin';")

        echo "not running"
        /etc/init.d/clamd restart

	sleep 20
	Var2=`/etc/init.d/clamd status`

        Var=`date`
        Var="$Var = clamd was stopped"
        echo $Var >> /usr/webcp/services/clamd_stopped.txt


	if [[ "$Var2" =~ "running" ]]
	then
		echo "On $Var, clamd was stopped... I did and automatic restart and clamd was successfully restarted!" | /usr/bin/mutt -s "CLAMD RESTARTED!!!!" "$EmailAddress"
	else
		echo "On $Var, clamd was stopped... I attempted an automatic restart but I could not restart clamd!" | /usr/bin/mutt -s "CLAMD STOPPED!!!!" "$EmailAddress"
	fi

	sleep 10
fi


