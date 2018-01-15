#!/bin/bash
exit

Password=`cat /usr/webcp/password`

UserName=$(mysql cpadmin -u root -p${Password} -se "SELECT value FROM server_settings WHERE setting = 'SCPUserName' AND deleted = 0;")
HostName=$(mysql cpadmin -u root -p${Password} -se "SELECT value FROM server_settings WHERE setting = 'SCPHost' AND deleted = 0;")
Directory=$(mysql cpadmin -u root -p${Password} -se "SELECT value FROM server_settings WHERE setting = 'SCPDirectory' AND deleted = 0;")
Port=$(mysql cpadmin -u root -p${Password} -se "SELECT value FROM server_settings WHERE setting = 'SCPPort' AND deleted = 0;")

`ssh -p ${Port} ${UserName}@${HostName} mkdir -p ${Directory}`
`ssh -p ${Port} ${UserName}@${HostName} rm -fr ${Directory}/*`

scp -P ${Port} /var/www/html/webcp/backups/daily/*.tar.gz ${UserName}@${HostName}:${Directory}/
