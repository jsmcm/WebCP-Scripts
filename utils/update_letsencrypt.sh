#!/bin/bash

x=$(pgrep update_letsencrypt.sh | wc -w)
if [ $x -gt 2 ]; then
        exit
fi

export DISPLAY=:0.0
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/root/bin
HOME=/root

source $HOME/.bash_profile

if [ -d "/etc/httpd/conf/ssl/letsencrypt" ]
then
	/etc/httpd/conf/ssl/letsencrypt/letsencrypt-auto
fi


