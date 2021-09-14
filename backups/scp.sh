#!/bin/bash
exit

Password=`/usr/webcp/get_password.sh`
User=`/usr/webcp/get_username.sh`
DB_HOST=`/usr/webcp/get_db_host.sh`

UserName=$(mysql cpadmin -u ${User} -p${Password} -h ${DB_HOST} -se "SELECT value FROM server_settings WHERE setting = 'SCPUserName' AND deleted = 0;")
HostName=$(mysql cpadmin -u ${User} -p${Password} -h ${DB_HOST} -se "SELECT value FROM server_settings WHERE setting = 'SCPHost' AND deleted = 0;")
Directory=$(mysql cpadmin -u ${User} -p${Password} -h ${DB_HOST} -se "SELECT value FROM server_settings WHERE setting = 'SCPDirectory' AND deleted = 0;")
Port=$(mysql cpadmin -u ${User} -p${Password} -h ${DB_HOST} -se "SELECT value FROM server_settings WHERE setting = 'SCPPort' AND deleted = 0;")

`ssh -p ${Port} ${UserName}@${HostName} mkdir -p ${Directory}`
`ssh -p ${Port} ${UserName}@${HostName} rm -fr ${Directory}/*`

scp -P ${Port} /var/www/html/backups/daily/*.tar.gz ${UserName}@${HostName}:${Directory}/
