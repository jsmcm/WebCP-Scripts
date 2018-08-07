#! /bin/bash

export DISPLAY=:0.0
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/root/bin
HOME=/root

source $HOME/.profile


Var=`service clamav-daemon status`

if [[ "$Var" =~ "running" ]]
then
        echo "running..."
else

	Password=`/usr/webcp/get_password.sh`
	EmailAddress=$(mysql cpadmin -u root -p${Password} -se "SELECT email_address FROM admin WHERE deleted = 0 AND role = 'admin';")

        echo "not running"
        service clamav-daemon restart

	sleep 5
	Var2=`service clamav-daemon status`

        echo $Var >> /usr/webcp/services/clamd_stopped.txt
        Var=`date`
        Var="$Var = clamd was stopped"
        echo $Var >> /usr/webcp/services/clamd_stopped.txt


	if [[ "$Var2" =~ "running" ]]
	then
		echo "On $Var, clamd was stopped... I did and automatic restart and clamd was successfully restarted!" | /usr/bin/mutt -s "CLAMD RESTARTED!!!!" "$EmailAddress"
	else
		echo "On $Var, clamd was stopped... I attempted an automatic restart but I could not restart clamd!" | /usr/bin/mutt -s "CLAMD STOPPED!!!!" "$EmailAddress"
	fi

fi


