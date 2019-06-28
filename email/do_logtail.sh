#!/bin/bash

x=$(pgrep do_logtail.sh | wc -w)
if [ $x -gt 2 ]; then
        exit
fi


if [ -f "/tmp/webcp/exim_trace_lock" ]
then
        if [ `stat --format=%Y /tmp/webcp/exim_trace_lock` -le $(( `date +%s` - (60*60) )) ]
        then
        	rm -fr /tmp/webcp/exim_trace_lock
	fi
fi


/usr/webcp/email/eximlogtail -f /var/log/exim4/mainlog | php /var/www/html/webcp/emails/trace/run_trace.php 
/usr/webcp/email/dovecotlogtail -f /var/log/dovecot/main.log | php /var/www/html/webcp/emails/trace/dovecot_bw.php 
/usr/webcp/email/ftplogtail -f /var/log/pureftpd.log | php /var/www/html/webcp/ftp/trace/ftp_bw.php 
