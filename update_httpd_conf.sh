#!/bin/bash

cd /usr/webcp/templates
wget http://webcp.pw/api/downloads/httpd.conf -nv -N -a /tmp/httpd.conf.log

if [ ! -s "/tmp/httpd.conf.log" ]
then
	/usr/webcp/redo_httpd_conf.sh
fi

rm -fr /tmp/httpd.conf.log

