#!/bin/bash

cd /etc/httpd/conf.d/
wget http://api.webcp.pw/downloads/modsecurity.conf -nv -N -a /tmp/modsecurity.conf.log

if [ -s "/tmp/modsecurity.conf.log" ]
then
	/etc/init.d/httpd graceful
fi

rm -fr /tmp/modsecurity.conf.log

