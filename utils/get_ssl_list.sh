#!/bin/bash

CSR=""
for FullFileName in /etc/nginx/ssl/*.csr;
do
	if [ -f $FullFileName ]
	then	
        	filename=$(basename "$FullFileName")
		filename=${filename%.*}

		if [ "$CSR" == "" ]
		then
			CSR="\"$filename\""
		else
			CSR="$CSR,\"$filename\""
		fi
	fi
done

CRT=""
for FullFileName in /etc/nginx/ssl/*.crt;
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


echo "{\"csr\":[$CSR],\"crt\":[$CRT]}"
