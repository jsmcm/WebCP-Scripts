#!/bin/bash

for FullFileName in /var/www/html/webcp/nm/*.cer;
do
        if [ -f $FullFileName ]
        then
		mv $FullFileName /etc/nginx/ssl
        fi
done

for FullFileName in /var/www/html/webcp/nm/*.crt;
do
        if [ -f $FullFileName ]
        then
		mv $FullFileName /etc/nginx/ssl
        fi
done
