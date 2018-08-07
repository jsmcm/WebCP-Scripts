#! /bin/bash

export DISPLAY=:0.0
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/root/bin
HOME=/root

source $HOME/.profile



echo "Checking nginx.."
Var=`service nginx status`

echo "Reply: $Var"
if [[ "$Var" =~ "running" ]]
then
        echo "running..."
else

	
		Password=`/usr/webcp/get_password.sh`
		EmailAddress=$(mysql cpadmin -u root -p${Password} -se "SELECT email_address FROM admin WHERE deleted = 0 AND role = 'admin';")
	
		echo "killing nginx"
	
	
	        echo "not running"
	        service nginx restart
	
		sleep 5
		Var2=`service nginx status`
	
	        echo $Var >> /usr/webcp/services/nginx_stopped.txt
	        Var=`date`
	        Var="$Var = nginx was stopped"
	        echo $Var >> /usr/webcp/services/nginx_stopped.txt
	
	
		if [[ "$Var2" =~ "running" ]]
		then
			echo "On $Var, nginx was stopped... I did and automatic restart and nginx was successfully restarted!" | /usr/bin/mutt -s "NGINX RESTARTED!!!!" "$EmailAddress"
		else
			echo "On $Var, nginx was stopped... I attempted an automatic restart but I could not restart nginx!" | /usr/bin/mutt -s "NGINX STOPPED!!!!" "$EmailAddress"
		fi
fi


