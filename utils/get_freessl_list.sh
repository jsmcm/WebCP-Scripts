#!/bin/bash

CRT=""
for FullFileName in /etc/letsencrypt/renewal/*.conf;
do
	if [ -f $FullFileName ]
	then	
        	filename=$(basename "$FullFileName")
		filename=${filename%.*}

		if [ "$CRT" == "" ]
		then
			CRT="\"$filename\""
		else
			CRT="$CRT,\"$filename\""
		fi
	fi
done


echo "{\"crt\":[$CRT]}"
