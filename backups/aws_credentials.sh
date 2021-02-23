#!/bin/bash

x=$(pgrep aws_credentials.sh | wc -w)
if [ $x -gt 2 ]; then
        exit
fi



	if [ -f "/var/www/html/webcp/nm/credentials.aws" ]
	then	

		rm -fr /root/.aws/credentials

		cp /var/www/html/webcp/nm/credentials.aws /root/.aws/credentials

		rm -fr /var/www/html/webcp/nm/credentials.aws
	fi

