#!/bin/bash
 
# Email alert cron job script for ClamAV
# Original, unmodified script by: Deven Hillard 
#(http://www.digitalsanctuary.com/tech-blog/debian/automated-clamav-virus-scanning.html)
# Modified to show infected and/or removed files

 
# Directories to scan
SCAN_DIR=$1
AGGRESSIVE=$2
 
# Location of log file
CurrentDate="$(date +"%Y-%m-%d")"
LOG_FILE="/var/log/clamav/clamscan_${CurrentDate}.log"
 
# Uncomment to have scan remove files
#AGGRESSIVE=1
# Uncomment to have scan not remove files
#AGGRESSIVE=0
 
# Email Subject
SUBJECT="WebCP - Infections detected on `hostname`"

# Email To
Password=`/usr/webcp/get_password.sh`
User=`/usr/webcp/get_username.sh`
DB_HOST=`/usr/webcp/get_db_host.sh`


EMAIL=$(mysql cpadmin -u ${User} -p${Password} -h ${DB_HOST} -se "SELECT email_address FROM admin WHERE role = 'admin' AND deleted = 0 LIMIT 1;")
EMAIL2=$(mysql cpadmin -u ${User} -p${Password} -h ${DB_HOST} -se "SELECT value FROM server_settings WHERE setting = 'ForwardSystemEmailsTo' AND deleted = 0;")


# Email From
EMAIL_FROM="root@`hostname`"
 
check_scan () {
    # If there were infected files detected, send email alert
 
    if [ `tail -n 12 ${LOG_FILE}  | grep 'Infected\|FOUND' | wc -l` != 0 ]
    then
    # Count number of infections
 
        EMAILMESSAGE=`mktemp /tmp/virus-alert.XXXXX`
        echo "To: ${EMAIL}" >>  ${EMAILMESSAGE}

	if [ -n "$EMAIL2" ]
	then
	        echo "Bcc: ${EMAIL2}" >>  ${EMAILMESSAGE}
	fi

        echo "From: ${EMAIL_FROM}" >>  ${EMAILMESSAGE}
        echo "Subject: ${SUBJECT}" >>  ${EMAILMESSAGE}
        echo "Importance: High" >> ${EMAILMESSAGE}
        echo "X-Priority: 1" >> ${EMAILMESSAGE}

	echo "The automatic virus scanner running in WebCP has detected some viruses on server: `hostname`. A partial list follows." >> ${EMAILMESSAGE}
        echo "" >>  ${EMAILMESSAGE}
	echo "The full list can be found at ${LOG_FILE}" >> ${EMAILMESSAGE}
        echo "" >>  ${EMAILMESSAGE}

	echo "NOTE: Infected files are not removed or quarantined. You must take manual action!!" >> ${EMAILMESSAGE}
        echo "" >>  ${EMAILMESSAGE}
        echo "====================================================================================================" >>  ${EMAILMESSAGE}
        echo "" >>  ${EMAILMESSAGE}
	     
       	echo -e "\n`tail -n 10 $LOG_FILE`" >> ${EMAILMESSAGE}
 
        sendmail -t < ${EMAILMESSAGE}
    fi
}
 
if [ $AGGRESSIVE = 1 ]
then
        /usr/bin/clamscan -ri --no-summary --remove $SCAN_DIR > $LOG_FILE
else
        /usr/bin/clamscan -ri --no-summary $SCAN_DIR > $LOG_FILE
fi
 
check_scan
