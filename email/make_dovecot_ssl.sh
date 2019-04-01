#!/bin/bash

CRT=""
for FullFileName in /etc/letsencrypt/renewal/*.conf;
do
	if [ -f $FullFileName ]
	then	
        	filename=$(basename "$FullFileName")
		filename=${filename%.*}

		CRT="$CRT\nlocal_name $filename {\n"
		CRT="${CRT}ssl_cert = </etc/letsencrypt/live/$filename/cert.pem\n"
		CRT="${CRT}ssl_key = </etc/letsencrypt/live/$filename/privkey.pem\n"
		CRT="${CRT}}\n"
	fi
done


if [ -f "/etc/dovecot/dovecot.pem" ]
then
	CRT="$CRT\nssl_cert = </etc/dovecot/dovecot.pem\n"
	CRT="$CRT\nssl_key = </etc/dovecot/privae/dovecot.pem\n"
elif [ -f "/etc/dovecot/dovecot.key" ]
then
	CRT="$CRT\nssl_cert = </etc/dovecot/private/dovecot.pem\n"
	CRT="$CRT\nssl_key = </etc/dovecot/private/dovecot.key\n"
elif [ -f "/etc/dovecot/ssl/dovecot.pem" ] && [ -f "/etc/dovecot/ssl/dovecot.key" ]
then
	CRT="$CRT\nssl_cert = </etc/dovecot/ssl/dovecot.pem\n"
	CRT="$CRT\nssl_key = </etc/dovecot/ssl/dovecot.key\n"
fi

CRT="$CRT\nssl = yes\n"


echo -e "$CRT" > /etc/dovecot/conf.d/10-ssl.conf

