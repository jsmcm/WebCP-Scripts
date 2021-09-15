#!/bin/bash

HOST=""

while IFS="=" read -r key value; 
do
    	case "$key" in
      		"DATABASE_HOST") HOST="$value" ;;
	esac
done < "/var/www/html/config.php"

size=${#HOST}
firstCharacter=${HOST:0:1}
lastCharacter=${HOST:$size-1:1}

if [ "$firstCharacter" == "\"" ] && [ "$lastCharacter" == "\"" ]
then
	HOST=${HOST:1}
	HOST=${HOST:0:$size-2}
fi

echo "${HOST//[$'\t\r\n ']}"
