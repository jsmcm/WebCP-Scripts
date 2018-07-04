#! /bin/bash

echo "Checking httpd.."
Var=`/etc/init.d/httpd status`

echo "Reply: $Var"
if [[ "$Var" =~ "running" ]]
then
        echo "running..."
else

	if [ -s /etc/httpd/conf/httpd.conf ]
	then
	
		Password=`/usr/webcp/get_password.sh`
		EmailAddress=$(mysql cpadmin -u root -p${Password} -se "SELECT email_address FROM admin WHERE deleted = 0 AND username = 'admin';")
	
		echo "killing httpd"
	
		kill -9 `ps ax | grep '\/usr\/sbin\/httpd' | awk ' { print $1;}'`
		killall -9 httpd
	
		#http://linuxtric.blogspot.co.za/2013/05/apache-semaphore-issue.html
		#https://major.io/2007/08/24/apache-no-space-left-on-device-couldnt-create-accept-lock/
		#for i in `ipcs -s | awk '/httpd/ {print $2}'`; do (ipcrm -s $i); done
		ipcs -s | grep apache | awk '{print $2;}' | while read -r line; do ipcrm sem "$line"; done
	
	        echo "not running"
	        /etc/init.d/httpd restart
	
		sleep 5
		Var2=`/etc/init.d/httpd status`
	
	        Var=`date`
	        Var="$Var = httpd was stopped"
	        echo $Var >> /usr/webcp/services/httpd_stopped.txt
	
	
		if [[ "$Var2" =~ "running" ]]
		then
			echo "On $Var, httpd was stopped... I did and automatic restart and httpd was successfully restarted!" | /usr/bin/mutt -s "HTTPD RESTARTED!!!!" "$EmailAddress"
		else
			echo "On $Var, httpd was stopped... I attempted an automatic restart but I could not restart httpd!" | /usr/bin/mutt -s "HTTPD STOPPED!!!!" "$EmailAddress"
		fi
	else
		echo "not here or blank!!!!"
		/usr/webcp/update_httpd_conf.sh
		/usr/webcp/redo_httpd_conf.sh
		exit
	fi

	sleep 10
fi


