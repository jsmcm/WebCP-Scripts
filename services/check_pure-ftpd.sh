#! /bin/bash

export DISPLAY=:0.0
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/root/bin
HOME=/root

source $HOME/.profile



Var=`service pure-ftpd-mysql status`

if [[ "$Var" =~ "running" ]]
then
        echo "running..."
else

	Password=`/usr/webcp/get_password.sh`
	EmailAddress=$(mysql cpadmin -u root -p${Password} -se "SELECT email_address FROM admin WHERE deleted = 0 AND role = 'admin';")

        echo "not running"
        service pure-ftpd-mysql restart

	sleep 5
	Var2=`service pure-ftpd-mysql status`

        Var=`date`
        Var="$Var = pure-ftpd-mysql was stopped"
        echo $Var >> /usr/webcp/services/pure-ftpd-mysql_stopped.txt


	if [[ "$Var2" =~ "running" ]]
	then
		echo "On $Var, pure-ftpd-mysql was stopped... I did and automatic restart and pure-ftpd-mysql was successfully restarted!" | /usr/bin/mutt -s "PURE-FTPD RESTARTED!!!!" "$EmailAddress"
	else
		echo "On $Var, pure-ftpd-mysql was stopped... I attempted an automatic restart but I could not restart pure-ftpd-mysql!" | /usr/bin/mutt -s "PURE-FTPD STOPPED!!!!" "$EmailAddress"
	fi
	

fi


