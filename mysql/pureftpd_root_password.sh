#!/bin/sh
Password=$1

if [ -z "$Password" ]; then
	echo "Please supply the password"
  	exit 1
fi

file=/etc/pure-ftpd/db/mysql.conf

OldPassword=`grep -i MYSQLPassword $file | head -1 | awk '{ print $2 }'`
cat $file | sed "s/$OldPassword/$Password/" > $file.new

if [ -s $file.new ]; then
	cp $file $file~ && mv $file.new $file
fi

service pure-ftpd-mysql restart


