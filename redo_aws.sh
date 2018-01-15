#!/bin/bash
Password=`cat /usr/webcp/password`

for DomainID in $(mysql cpadmin -u root -p${Password} -se "SELECT id FROM domains WHERE domain_type = 'primary' AND deleted = 0;")
do

	DomainName=$(mysql cpadmin -u root -p${Password} -se "SELECT fqdn FROM domains WHERE deleted = 0 AND id = $DomainID;")
	UserName=$(mysql cpadmin -u root -p${Password} -se "SELECT UserName FROM domains WHERE deleted = 0 AND id = $DomainID;")
		
	rm -fr /etc/awstats/awstats.$DomainName.conf
	
	cat /usr/webcp/templates/awstats.sample.conf | \
	sed -e "s/\\\$DOMAIN/$DomainName/g" | \
	sed -e "s/\\\$USERNAME/$UserName/g" | \
	sed -e "s/\\\$ALIASES/$ALIASES/g" > \
	"/etc/awstats/awstats.$DomainName.conf"

done
	
