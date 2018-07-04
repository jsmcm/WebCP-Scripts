#!/bin/bash

PASSWORD=""

while IFS="=" read -r key value; 
do
    	case "$key" in
      		"DATABASE_PASSWORD") PASSWORD="$value" ;;
	esac
done < "/var/www/html/config.php"

echo "$PASSWORD"
