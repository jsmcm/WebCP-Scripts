#!/bin/bash

PASSWORD=""

while IFS="=" read -r key value; 
do
    	case "$key" in
      		"DATABASE_PASSWORD") PASSWORD="$value" ;;
	esac
done < "/var/www/html/config.php"

size=${#PASSWORD}
firstCharacter=${PASSWORD:0:1}
lastCharacter=${PASSWORD:$size-1:1}

if [ "$firstCharacter" == "\"" ] && [ "$lastCharacter" == "\"" ]
then
	PASSWORD=${PASSWORD:1}
	PASSWORD=${PASSWORD:0:$size-2}
fi

echo "${PASSWORD//[$'\t\r\n ']}"
