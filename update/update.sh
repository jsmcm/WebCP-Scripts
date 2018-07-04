#!/bin/bash

Password=`/usr/webcp/get_password.sh`
CurrentTime="$(date +"%Y-%m-%d_%H-%M-%S")"
IP=`cat /var/www/html/webcp/includes/ip.txt`

#echo "At top of update.sh" >> /usr/webcp/services/log.log

if [ -f "/var/www/html/webcp/tmp/usr_webcp_scripts.zip" ]
then
	cd /usr/webcp
	zip backups_$CurrentTime * *.* -r
	rm -fr /usr/webcp/scripts.zip
	mv /var/www/html/webcp/tmp/usr_webcp_scripts.zip /usr/webcp/scripts.zip
	unzip -o scripts.zip
	rm -fr /usr/webcp/scripts.zip
	chmod 755 /usr/webcp/* -R
	chmod 755 /usr/webcp/*.* -R
fi

#echo "checking for /var/www/html/webcp/tmp/exim_scripts.zip" >> /usr/webcp/services/log.log
if [ -f "/var/www/html/webcp/tmp/exim_scripts.zip" ]
then
	#echo "its here..." >> /usr/webcp/services/log.log
	cd /usr/webcp/templates
	zip exim_backup_$CurrentTime.zip exim* -r
	rm -fr /usr/webcp/templates/exim_scripts.zip
	mv /var/www/html/webcp/tmp/exim_scripts.zip /usr/webcp/templates
	unzip -o exim_scripts.zip
	rm -fr /usr/webcp/templates/exim_scripts.zip
	chmod 755 /usr/webcp/templates/*.* -R
	chmod 755 /usr/webcp/templates/* -R
	/usr/webcp/mysql/exim_root_password.sh $Password
fi

if [ -f "/var/www/html/webcp/tmp/httpd_scripts.zip" ]
then
	cd /usr/webcp/templates
	zip httpd_backup_$CurrentTime.zip httpd.conf
	rm -fr /usr/webcp/templates/httpd_scripts.zip
	mv /var/www/html/webcp/tmp/httpd_scripts.zip /usr/webcp/templates
	unzip -o httpd_scripts.zip
	rm -fr /usr/webcp/templates/httpd_scripts.zip

	cp /usr/webcp/templates/httpd.conf /usr/webcp/templates/httpd.tmp
	replace "NameVirtualHost *" "NameVirtualHost $IP" -- /usr/webcp/templates/httpd.tmp

	rm -fr /etc/httpd/conf/httpd.conf
	mv /usr/webcp/templates/httpd.tmp /etc/httpd/conf/httpd.conf
	/etc/init.d/httpd graceful
fi

if [ -f "/var/www/html/webcp/tmp/crontab_scripts.zip" ]
then
	cd /usr/webcp/templates
	zip crontab_backup_$CurrentTime.zip crontab
	rm -fr /usr/webcp/templates/crontab_scripts.zip
	mv /var/www/html/webcp/tmp/crontab_scripts.zip /usr/webcp/templates
	unzip -o crontab_scripts.zip
	rm -fr /usr/webcp/templates/crontab_scripts.zip

	rm -fr /etc/crontab
	cp /usr/webcp/templates/crontab /etc/crontab
	chmod 644 /etc/crontab
	
	pkill -9 bck_jobs.sh
	pkill -9 domains_jobs.sh
	pkill -9 fwd_jobs.sh
	pkill -9 f2b_jobs.sh
	pkill -9 web_install.sh
	pkill -9 sus_jobs.sh
	pkill -9 db_jobs.sh
	pkill -9 rst_jobs.sh


	/etc/init.d/crond restart
fi



if [ -f "/var/www/html/webcp/tmp/etc_skel_editor.zip" ]
then
	cd /etc/skel
	zip editor_$CurrentTime.zip .editor -r
	mv /var/www/html/webcp/tmp/etc_skel_editor.zip /etc/skel
	unzip -o etc_skel_editor.zip
	/usr/webcp/update/cp_ed2us.sh
	rm -fr /etc/skel/etc_skel_editor.zip
fi
