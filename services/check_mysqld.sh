#! /bin/bash

Var=`/etc/init.d/mysqld status`

if [[ "$Var" =~ "running" ]]
then
        echo "running..."
else

	Password=`cat /usr/webcp/password`
	EmailAddress=$(mysql cpadmin -u root -p${Password} -se "SELECT email_address FROM admin WHERE deleted = 0 AND username = 'admin';")

        echo "not running"
        /etc/init.d/mysqld restart

	sleep 5
	Var2=`/etc/init.d/mysqld status`

        Var=`date`
        Var="$Var = mysqld was stopped"
        echo $Var >> /usr/webcp/services/mysqld_stopped.txt


	if [[ "$Var2" =~ "running" ]]
	then
		echo "On $Var, mysqld was stopped... I did and automatic restart and mysqld was successfully restarted!" | /usr/bin/mutt -s "MYSQLD RESTARTED!!!!" "$EmailAddress"
	else
		echo "On $Var, mysqld was stopped... I attempted an automatic restart but I could not restart mysqld!" | /usr/bin/mutt -s "MYSQLD STOPPED!!!!" "$EmailAddress"
	fi

	sleep 10
fi


