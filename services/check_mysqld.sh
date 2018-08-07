#! /bin/bash

export DISPLAY=:0.0
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/root/bin
HOME=/root

source $HOME/.profile




Var=`service mysql status`

if [[ "$Var" =~ "running" ]]
then
        echo "running..."
else
	Password=`/usr/webcp/get_password.sh`
	EmailAddress=$(mysql cpadmin -u root -p${Password} -se "SELECT email_address FROM admin WHERE deleted = 0 AND role = 'admin';")

        echo "not running"
        service mysql restart

	sleep 5
	Var2=`service mysql status`

        Var=`date`
        Var="$Var = mysql was stopped"
        echo $Var >> /usr/webcp/services/mysql_stopped.txt


	if [[ "$Var2" =~ "running" ]]
	then
		echo "On $Var, mysql was stopped... I did and automatic restart and mysql was successfully restarted!" | /usr/bin/mutt -s "MYSQLD RESTARTED!!!!" "$EmailAddress"
	else
		echo "On $Var, mysql was stopped... I attempted an automatic restart but I could not restart mysql!" | /usr/bin/mutt -s "MYSQLD STOPPED!!!!" "$EmailAddress"
	fi

fi


