#!/bin/bash
x=`free -b`
total=`echo $x | cut -d' ' -f 8`
available=`echo $x | cut -d' ' -f 13`

used=$(($total-$available))

Password=`/usr/webcp/get_password.sh`
User=`/usr/webcp/get_username.sh`
DB_HOST=`/usr/webcp/get_db_host.sh`

DATE=$(date +"%Y-%m-%d %H:%M:%S")

DomainName=$(mysql cpadmin -u ${User} -p${Password} -h ${DB_HOST} -se "INSERT INTO server_stats VALUES (0, 'ram', '$total', '$used', '$available', '$DATE', 0);")
