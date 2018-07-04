#! /bin/bash

Var=`service exim status`

echo "$Var"
echo ""

if [[ "$Var" =~ "Active: active" ]]
then
        echo "running..."
else

	Password=`/usr/webcp/get_password.sh`

	EmailAddress=$(mysql cpadmin -u root -p${Password} -se "SELECT email_address FROM admin WHERE deleted = 0 AND username = 'admin';")

        echo "not running"
        service exim restart

	sleep 5
	Var2=`service exim status`

        Var=`date`
        Var="$Var = exim was stopped"
        echo $Var >> /usr/webcp/services/exim_stopped.txt


	if [[ "$Var2" =~ "Active: active" ]]
	then
		echo "On $Var, exim was stopped... I did and automatic restart and exim was successfully restarted!" | /usr/bin/mutt -s "EXIM RESTARTED!!!!" "$EmailAddress"
	else
		echo "On $Var, exim was stopped... I attempted an automatic restart but I could not restart exim!" | /usr/bin/mutt -s "EXIM STOPPED!!!!" "$EmailAddress"
	fi

	sleep 10
fi


