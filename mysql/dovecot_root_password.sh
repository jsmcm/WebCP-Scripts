#!/bin/bash

Password=$1

if [ -z "$Password" ]
then
	echo "Please supply the password"
	exit
fi

echo "driver = mysql" > /etc/dovecot/dovecot-sql.conf
echo "connect = \"host=localhost dbname=cpadmin user=root password=$Password\"" >> /etc/dovecot/dovecot-sql.conf
echo "default_pass_scheme = PLAIN-MD5" >> /etc/dovecot/dovecot-sql.conf
echo "password_query = SELECT CONCAT(mailboxes.local_part,'@',domains.fqdn) as \`user\`,mailboxes.password AS \`password\`,'/var/spool/mail/%d/%n' AS \`userdb_home\`, Uid AS \`userdb_uid\`, Gid AS \`userdb_gid\` FROM \`mailboxes\`, \`domains\` WHERE mailboxes.local_part = '%n' AND mailboxes.active = 1 AND mailboxes.domain_id = domains.id AND domains.fqdn = '%d' AND domains.active = 1 AND domains.deleted = 0 AND domains.suspended = 0" >> /etc/dovecot/dovecot-sql.conf
echo "user_query = SELECT '/var/spool/mail/%d/%n' AS \`home\`, CONCAT('maildir:/home/', UserName, '/mail/%d/%n') AS \`mail\`, Uid AS \`uid\`, Gid AS \`gid\` FROM \`mailboxes\`, \`domains\` WHERE mailboxes.local_part = '%n' AND mailboxes.active = 1 AND mailboxes.domain_id = domains.id AND domains.fqdn = '%d' AND domains.active = 1 AND domains.deleted = 0 AND domains.suspended = 0" >> /etc/dovecot/dovecot-sql.conf

/etc/init.d/dovecot restart

