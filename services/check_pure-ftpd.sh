#! /bin/bash

Var=`/etc/init.d/pure-ftpd status`

if [[ "$Var" =~ "running" ]]
then
        echo "running..."
else

	Password=`cat /usr/webcp/password`
	EmailAddress=$(mysql cpadmin -u root -p${Password} -se "SELECT email_address FROM admin WHERE deleted = 0 AND username = 'admin';")

        echo "not running"
        /etc/init.d/pure-ftpd restart

	sleep 5
	Var2=`/etc/init.d/pure-ftpd status`

        Var=`date`
        Var="$Var = pure-ftpd was stopped"
        echo $Var >> /usr/webcp/services/pure-ftpd_stopped.txt


	if [[ "$Var2" =~ "running" ]]
	then
		echo "On $Var, pure-ftpd was stopped... I did and automatic restart and pure-ftpd was successfully restarted!" | /usr/bin/mutt -s "PURE-FTPD RESTARTED!!!!" "$EmailAddress"
	else
		echo "On $Var, pure-ftpd was stopped... I attempted an automatic restart but I could not restart pure-ftpd!" | /usr/bin/mutt -s "PURE-FTPD STOPPED!!!!" "$EmailAddress"
	fi
	

	sleep 10
fi


