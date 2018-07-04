#!/bin/bash

DomainUserName=$1
RandomPath=$2

Password=`/usr/webcp/get_password.sh`

if [ "$DomainUserName" == "" ]
then
        echo ""
        echo "Please supply args!!!"
        echo "mysql_dump.sh DomainUserName RandomPath"
        echo "eg, mysql_dump.sh examplec DSF324DF"
        exit
fi

if [ "$RandomPath" == "" ]
then
        echo ""
        echo "Please supply args!!!"
        echo "mysql_dump.sh DomainUserName RandomPath"
        echo "eg, mysql_dump.sh examplec DSF324DF"
        exit
fi

if [ ! -d "/var/www/html/webcp/backups/tmp" ]; then
	mkdir /var/www/html/webcp/backups/tmp
fi

if [ ! -d "/var/www/html/webcp/backups/tmp/$RandomPath" ]; then
	mkdir /var/www/html/webcp/backups/tmp/$RandomPath
fi

if [ ! -d "/var/www/html/webcp/backups/tmp/$RandomPath/sql" ]; then
	mkdir /var/www/html/webcp/backups/tmp/$RandomPath/sql
fi

	for NextDatabase in $(mysql cpadmin -u root -p${Password} -se "SELECT database_name FROM mysql WHERE deleted = 0 AND domain_username = '$DomainUserName';")
	do
		nice /usr/bin/mysqldump --routines -u root -p${Password} $NextDatabase >> /var/www/html/webcp/backups/tmp/$RandomPath/sql/$NextDatabase.sql	
	done

