#!/bin/bash

source /root/.bashrc
if [ $(pgrep director.sh| wc -w) -gt 2 ]; then
	exit
fi

SECONDS=0
MINUTES=0
HOURS=0

TenMinutesRunOnce=0

mkdir -p /tmp/webcp
chgrp www-data /tmp/webcp -R
chmod 775 /tmp/webcp -R

while : 
do

	ADD_SPAM_ASSASSIN_SH=0
	DELETE_SPAM_ASSASSIN_SH=0
	CATCHALL_SH=0
	DOMAINS_SH=0
	COMPOSER_SH=0
	DELETE_ACCOUNT_SH=0
	MYSQL_DO_CHANGE_ROOT_SH=0
	MKEMAIL_SH=0
	PASSWORDWRAPPER_SH=0
	MAIL_FORWARD_SH=0
	MAIL_AUTO_REPLY_SH=0
	SSL_SH=0
	FREESSL_SH=0
	DELETE_SSL_SH=0
	DELETE_FREESSL_SH=0
        BACKUPS_DO_BACKUP_SH=0
	CRT_SH=0
	DELEMAIL_SH=0
	DELDIRS_SH=0
	LETSENCRYPT_INSTALL_SH=0
	USER_QUOTA_SH=0
	SUSPENSION_SH=0
	RESTORE_DO_RESTORE_SH=0
	WEB_INSTALL_SH=0
	EMAIL_WHITELIST_SH=0
	DNS_SH=0
	UNBAN_SH=0
	BAN_SH=0
	PERM_UNBAN_SH=0
	PERM_BAN_SH=0

	MD5=`md5sum /usr/webcp/director.sh | awk '{print $1}'`
	echo "this md5 '$MD5'"
	
	if [ ! -f "/tmp/webcp/director.md5" ]
	then
		echo "Making MD5 file"
		echo "$MD5" > /tmp/webcp/director.md5
		exit
	fi

	StoredMD5=`cat /tmp/webcp/director.md5`
	echo "Stored md5 '$StoredMD5'"

	if [ "$MD5" != "$StoredMD5" ]
	then
		echo "file changed!"
		echo "$MD5" > /tmp/webcp/director.md5
		exit
	fi

		

	if [ -f "/usr/webcp/director.reboot" ]
	then
		rm -fr /usr/webcp/director.reboot
		exit
	fi 

	target="/var/www/html/webcp/nm"
	if find "$target" -mindepth 1 -print -quit | grep -q .
	then    
		echo "Something here"
	
		for FullFileName in /var/www/html/webcp/nm/.* /var/www/html/webcp/nm/* ;
		do
	
	        	if [ -f $FullFileName ]
		        then
				filename=$(basename "$FullFileName")
				extension="${filename##*.}"
	
				echo "filename: $filename"
				echo "extension: $extension"
				echo "---------------"
				echo ""
	
				if [ "$extension" == "subdomain" ]	
				then
					DOMAINS_SH=1
				elif [ "$extension" == "uquota" ]	
				then
					USER_QUOTA_SH=1
				elif [ "$extension" == "wp" ]	
				then
					WEB_INSTALL_SH=1
				elif [ "$extension" == "add_spamassassin" ]	
				then
					ADD_SPAM_ASSASSIN_SH=1
				elif [ "$extension" == "delete_spamassassin" ]	
				then
					DELETE_SPAM_ASSASSIN_SH=1
				elif [ "$extension" == "suspend" ]	
				then
					SUSPENSION_SH=1
				elif [ "$extension" == "unsuspend" ]	
				then
					SUSPENSION_SH=1
				elif [ "$extension" == "unban" ]	
				then
					UNBAN_SH=1
				elif [ "$extension" == "ban" ]	
				then
					BAN_SH=1
				elif [ "$extension" == "permunban" ]	
				then
					PERM_UNBAN_SH=1
				elif [ "$extension" == "permban" ]	
				then
					PERM_BAN_SH=1
				elif [ "$extension" == "dma" ]	
				then
					DELEMAIL_SH=1
				elif [ "$extension" == "dml" ]	
				then
					DELDIRS_SH=1
				elif [ "$extension" == "delete_domain" ]	
				then
					DELETE_ACCOUNT_SH=1
				elif [ "$extension" == "nma" ]	
				then
					MKEMAIL_SH=1
				elif [ "$extension" == "mailpassword" ]	
				then
					PASSWORDWRAPPER_SH=1
				elif [ "$filename" == "root.password" ]
				then
					MYSQL_DO_CHANGE_ROOT_SH=1
				elif [ "$filename" == "whitelist" ]
				then
					EMAIL_WHITELIST_SH=1
				elif [ "$filename" == "letsencrypt.install" ]
				then
					LETSENCRYPT_INSTALL_SH=1
					rm -fr $FullFileName
                                elif [ "$extension" == "delete_single_forwards" ]
                                then
                                        MAIL_FORWARD_SH=1
                                
				elif [ "$extension" == "catchall" ]
                                then
                                        CATCHALL_SH=1


				elif [ "$filename" == "composer_install" ]
				then
					COMPOSER_SH=1

				elif [ "${filename:0:10}" == "named.conf" ]
				then
					DNS_SH=1
                                elif [ "$extension" == "dnsadd" ]
                                then
					DNS_SH=1
                                elif [ "$extension" == "dnsdel" ]
                                then
					DNS_SH=1


                                elif [ "$extension" == "crt" ]
                                then
                                       	CRT_SH=1
                                elif [ "$extension" == "backup" ]
                                then
                                       BACKUPS_DO_BACKUP_SH=1
                                elif [ "$extension" == "ssl" ]
                                then
                                       	SSL_SH=1
                                elif [ "$extension" == "freessl" ]
                                then
                                       	FREESSL_SH=1
                                elif [ "$extension" == "restore" ]
                                then
					RESTORE_DO_RESTORE_SH=1
                                elif [ "$extension" == "singleforward" ]
                                then
                                        MAIL_FORWARD_SH=1
                                elif [ "$extension" == "forward_address" ]
                                then
                                        MAIL_FORWARD_SH=1
				elif [ "$extension" == "autoreply" ]
                                then
                                        MAIL_AUTO_REPLY_SH=1
				elif [ "$extension" == "deletessl" ]
                                then
                                        DELETE_SSL_SH=1
				elif [ "$extension" == "deletefreessl" ]
                                then
                                        DELETE_FREESSL_SH=1
				elif [ "$extension" == "backup" ]
                                then
                                        BACKUP_DO_BACKUP_SH=1
				fi
			fi
		done
	fi
	

	echo "LETSENCRYPT_INSTALL_SH: $LETSENCRYPT_INSTALL_SH"
	if [ "$LETSENCRYPT_INSTALL_SH" == 1 ]
	then
		/usr/webcp/utils/install_letsencrypt.sh &
	fi 
	
	echo "SUSPENSION_SH: $SUSPENSION_SH"
	if [ "$SUSPENSION_SH" == 1 ]
	then
		/usr/webcp/suspension.sh &
	fi 
	
	
	echo "ADD_SPAM_ASSASSIN_SH: $ADD_SPAM_ASSASSIN_SH"
	if [ "$ADD_SPAM_ASSASSIN_SH" == 1 ]
	then
		/usr/webcp/email/spamassassin.sh &
	fi 
	
	echo "DELETE_SPAM_ASSASSIN_SH: $DELETE_SPAM_ASSASSIN_SH"
	if [ "$DELETE_SPAM_ASSASSIN_SH" == 1 ]
	then
		/usr/webcp/email/delete_spamassassin.sh &
	fi 

	echo "CRT_SH: $CRT_SH"
	if [ "$CRT_SH" == 1 ]
	then
		/usr/webcp/crt.sh &
	fi 
	
	echo "DNS_SH: $DNS_SH"
	if [ "$DNS_SH" == 1 ]
	then
		/usr/webcp/dns.sh &
	fi 
	
	echo "DELEMAIL_SH: $DELEMAIL_SH"
	if [ "$DELEMAIL_SH" == 1 ]
	then
		/usr/webcp/email/delemail.sh &
	fi 
	
	echo "DELDIRS_SH: $DELDIRS_SH"
	if [ "$DELDIRS_SH" == 1 ]
	then
		/usr/webcp/deldirs.sh &
	fi 
	
	
	echo "DELETE_FREESSL_SH: $DELETE_FREESSL_SH"
	if [ "$DELETE_FREESSL_SH" == 1 ]
	then
		/usr/webcp/delete_freessl.sh &
	fi 
	
	echo "DELETE_SSL_SH: $DELETE_SSL_SH"
	if [ "$DELETE_SSL_SH" == 1 ]
	then
		/usr/webcp/delete_ssl.sh &
	fi 
	
	echo "DELETE_ACCOUNT_SH: $DELETE_ACCOUNT_SH"
	if [ "$DELETE_ACCOUNT_SH" == 1 ]
	then
		/usr/webcp/delete_account.sh &
	fi 

	echo "MYSQL_DO_CHANGE_ROOT_SH: $MYSQL_DO_CHANGE_ROOT_SH"
	if [ "$MYSQL_DO_CHANGE_ROOT_SH" == 1 ]
	then
		/usr/webcp/mysql/do_change_root.sh &
	fi 
	
	echo "MKEMAIL_SH: $MKEMAIL_SH"
	if [ "$MKEMAIL_SH" == 1 ]
	then
	 	/usr/webcp/email/mkemail.sh &
	fi  
	
	echo "PASSWORDWRAPPER_SH: $PASSWORDWRAPPER_SH"
	if [ "$PASSWORDWRAPPER_SH" == 1 ]
	then
	 	/usr/webcp/email/passwordwrapper.sh &
	fi  
	
        echo "CATCHALL_SH: $CATCHALL_SH"
        if [ "$CATCHALL_SH" == 1 ]
        then
                /usr/webcp/email/catchall.sh &
        fi
	
	
	
        echo "MAIL_FORWARD_SH: $MAIL_FORWARD_SH"
        if [ "$MAIL_FORWARD_SH" == 1 ]
        then
                /usr/webcp/mail_forward.sh &
                /usr/webcp/email/touchforwardaddress.sh &
	fi
	
        if [ "$MAIL_AUTO_REPLY_SH" == 1 ]
        then
                /usr/webcp/mail_auto_reply.sh &
        fi
	
        if [ "$SSL_SH" == 1 ]
        then
                /usr/webcp/ssl.sh &
        fi
        
        if [ "$FREESSL_SH" == 1 ]
        then
                /usr/webcp/freessl.sh &
        fi
	
        if [ "$BACKUPS_DO_BACKUP_SH" == 1 ]
        then
                /usr/webcp/backups/do_backup.sh &
        fi
        
        if [ "$USER_QUOTA_SH" == 1 ]
        then
		/usr/webcp/user_quota.sh &
        fi
	
	
	if [ "$COMPOSER_SH" == 1 ]
	then
		/usr/webcp/composer.sh &
	fi 

	
	if [ "$DOMAINS_SH" == 1 ]
	then
		/usr/webcp/domains/domains.sh &
	fi 

	if [ "$UNBAN_SH" == 1 ]
	then
		/usr/webcp/fail2ban/unban.sh &
	fi

	if [ "$BAN_SH" == 1 ]
	then
		/usr/webcp/fail2ban/ban.sh &
	fi
	
	if [ "$PERM_UNBAN_SH" == 1 ]
	then
		/usr/webcp/fail2ban/permunban.sh &
	fi

	if [ "$PERM_BAN_SH" == 1 ]
	then
		/usr/webcp/fail2ban/permban.sh &
	fi


	if [ "$WEB_INSTALL_SH" == 1 ]
	then
		/usr/webcp/web_install.sh &
	fi 

	if [ "$EMAIL_WHITELIST_SH" == 1 ]
	then
		/usr/webcp/email/whitelst.sh &
	fi 

	if [ "$RESTORE_DO_RESTORE_SH" == 1 ]
	then
		/usr/webcp/restore/do_restore.sh &
	fi 



	sleep 3

	duration=$SECONDS
	if [ $duration -gt 59 ]
	then
		let "MINUTES=MINUTES+1"
		SECONDS=0
	
		/usr/webcp/email/do_logtail.sh &

		/usr/webcp/stats/cpu.sh &

		echo "Testing connection to http through cron page" >> /tmp/http.log
		RESULT="`wget -qO- --timeout=5 --tries=10 http://localhost:8880/includes/cron/index.php`"
		echo "RESULT FROM WGET LOCALHOST: '$RESULT'" >> /tmp/http.log

		if $( echo $RESULT | grep --quiet 'cron_ok' )
		then
			echo "httpd ok..." >> /tmp/http.log
		else
			echo "httpd stalled..." >> /tmp/http.log
			echo " " >> /tmp/http.log
			echo "ps ax | grep httpd" >> /tmp/http.log
			RESULT="`ps ax | grep httpd`" >> /tmp/http.log
			echo "$RESULT" >> /tmp/http.log
			echo " " >> /tmp/http.log
			RESULT="`ipcs -s | grep apache | wc -l`"
			echo "ipcs -s | grep apache ($RESULT)" >> /tmp/http.log
			RESULT="`ipcs -s | grep apache`"
			echo "$RESULT" >> /tmp/http.log
			/etc/init.d/httpd stop
			pkill -9 httpd
		fi
		
		echo " " >> /tmp/http.log
		echo "------------------------------------" >> /tmp/http.log
		echo " " >> /tmp/http.log

		/usr/webcp/services/srv_jobs.sh & 
	fi

		
	if [ $(($MINUTES % 10)) == 0 ]
	then
		if [ $TenMinutesRunOnce == 0 ]
		then
			/usr/webcp/server.sh &
			/usr/webcp/stats/ram.sh &
			TenMinutesRunOnce=1
		fi
	else
		TenMinutesRunOnce=0
	fi

	if [ $MINUTES -gt 59 ]
	then
		MINUTES=0
		let "HOURS=HOURS+1"
		/usr/webcp/bandwidth/bandwidth.sh &
		/usr/webcp/skel/skel.sh &
		/usr/webcp/check_quota.sh &
		/usr/webcp/email/bayes_learn.sh &
	fi

	if [ $HOURS -gt 23 ]
	then	
	
		echo "IN 24 hours!!!" >> /home/24
		HOURS=0
		/usr/webcp/email/dkim.sh &
		/usr/webcp/utils/update_letsencrypt.sh &
		/usr/webcp/f2b_spamhause.sh & 
		/usr/webcp/dele_tmp.sh &
		/usr/bin/freshclam --quiet &
		/usr/webcp/virus/scan.sh /home/*/public_html 0 &
		/usr/webcp/virus/scan.sh /home/*/mail 1 &
		sa-update && service spamassassin restart &
		/usr/webcp/modsec.sh &
		/usr/webcp/bandwidth/del_stale.sh &
		/usr/webcp/update_modsecurity_conf.sh &
		/usr/webcp/update/update.sh &
		/usr/webcp/freerenew.sh
		exit
	fi

	echo ""
	echo "-----------------------------------------"
	echo ""
done

