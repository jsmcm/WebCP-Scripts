#!/bin/bash

x=$(pgrep aws_config.sh | wc -w)
if [ $x -gt 2 ]; then
        exit
fi



	if [ -f "/var/www/html/webcp/nm/config.aws" ]
	then	

		rm -fr /root/.aws/config

		cp /var/www/html/webcp/nm/config.aws /root/.aws/config

		rm -fr /var/www/html/webcp/nm/config.aws
	fi

