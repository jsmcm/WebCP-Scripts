#!/bin/bash

cd /etc/mail/spamassassin
wget http://api.webcp.pw/downloads/local.cf -nv -N -a /tmp/local.cf.log

if [ -s "/tmp/local.cf.log" ]
then
	/etc/init.d/exim stop
	/etc/init.d/spamassassin stop
	/etc/init.d/spamassassin start
	/etc/init.d/exim start
fi

rm -fr /tmp/local.cf.log

