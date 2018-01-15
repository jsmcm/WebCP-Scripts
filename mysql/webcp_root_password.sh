#!/bin/sh
Password=$1
Password="\"$Password\";"

if [ -z "$Password" ]; then
	echo "Please supply the password"
  	exit 1
fi

file=/var/www/html/webcp/includes/Variables.inc

OldPassword=`grep -i DatabasePassword\ = $file | head -1 | awk '{ print $3 }'`

echo "Old Password: $OldPassword"

cat $file | sed "s/$OldPassword/$Password/" > $file.new

if [ -s $file.new ]; then
	cp $file $file~ && mv $file.new $file
fi


