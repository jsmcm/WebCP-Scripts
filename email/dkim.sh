#!/bin/bash

	if [ ! -d /etc/exim4/dkim ]
	then	
		mkdir /etc/exim4/dkim
	fi

	if [ -d /etc/exim4/dkim ]
	then
		chgrp www-data /etc/exim4/dkim
		chmod 0775 /etc/exim4/dkim
	fi

	if [ ! -e /etc/exim4/dkim.private.key ]
	then	
		openssl genrsa -out /etc/exim4/dkim.private.key 1024
		chown Debian-exim.Debian-exim /etc/exim4/dkim.private.key
	fi

	if [ ! -e /etc/exim4/dkim.public.key ]
	then	
		openssl rsa -in /etc/exim4/dkim.private.key -out /etc/exim4/dkim.public.key -pubout -outform PEM
		chown Debian-exim.Debian-exim /etc/exim4/dkim.public.key
	fi

exit
