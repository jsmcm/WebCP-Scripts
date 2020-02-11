#!/bin/bash

x=$(pgrep update_letsencrypt.sh | wc -w)
if [ $x -gt 2 ]; then
        exit
fi

export DISPLAY=:0.0
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/root/bin
HOME=/root

source $HOME/.profile

if [ -d "/etc/nginx/ssl/letsencrypt" ]
then
	echo "running letsencrypt-auto renew" >> /usr/webcp/utils/debug
	out=`/etc/nginx/ssl/letsencrypt/letsencrypt-auto renew`
	echo "out = $out" >> /usr/webcp/utils/debug
fi


