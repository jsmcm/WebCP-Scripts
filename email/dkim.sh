#!/bin/bash

	if [ ! -d /etc/exim/dkim ]
	then	
		mkdir /etc/exim/dkim
	fi

	if [ -d /etc/exim/dkim ]
	then
		chgrp apache /etc/exim/dkim
		chmod 0775 /etc/exim/dkim
	fi

	if [ ! -e /etc/exim/dkim.private.key ]
	then	
		openssl genrsa -out /etc/exim/dkim.private.key 1024
	fi

	if [ ! -e /etc/exim/dkim.public.key ]
	then	
		openssl rsa -in /etc/exim/dkim.private.key -out /etc/exim/dkim.public.key -pubout -outform PEM
	fi

exit
