#!/bin/bash

USER=""

while IFS="=" read -r key value; 
do
    	case "$key" in
      		"DATABASE_USER") USER="$value" ;;
	esac
done < "/var/www/html/config.php"

size=${#USER}
firstCharacter=${USER:0:1}
lastCharacter=${USER:$size-1:1}

if [ "$firstCharacter" == "\"" ] && [ "$lastCharacter" == "\"" ]
then
	USER=${USER:1}
	USER=${USER:0:$size-2}
fi

echo "${USER//[$'\t\r\n ']}"
