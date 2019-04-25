#!/bin/bash
/etc/nginx/ssl/letsencrypt/letsencrypt-auto renew
CurrentDate="$(date +"%Y-%m-%d")"
#echo "Ran renewFree on $CurrentDate" >> /usr/webcp/freerenew.log

chmod 755 /etc/letsencrypt/{archive,live} -R
chgrp Debian-exim /etc/letsencrypt/{archive,live} -R

