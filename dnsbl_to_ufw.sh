#!/bin/bash

#dnsbl.softsmart.co.za is a dnsbl which uses spam traps to catch spammers and list their ips / usernames / emails
# Ips must be reversed, but emails / usernames not.
# eg, check IP 10.20.30.40 -> dig 40.30.20.10.dnsbl.softsmart.co.za
# eg, check email joe@example.com -> dig john@example.com.dnsbl.softsmart.co.za
# no record means that the ip / text is not listed
# 127.0.0.1 means its an ip listed
# 127.0.0.2 means its a text value listed (email or username)



#ufw insert 1 deny from 1.2.3.4 comment 'dnsbl.softsmart.co.za'

ufwvar=`ufw status | grep dnsbl.softsmart.co.za`

touch /tmp/dnsbl

while IFS= read -r line
do
   
   if [ -z "$line" ]
   then
	   continue
   fi


   action=`echo $line | cut -d' ' -f 2`
   if [ $action == "DENY" ]
   then
	   action="deny"
   fi

   ip=`echo $line | cut -d' ' -f 3`

   
   if [ ! -z "$action" ]
   then
   	ufw delete $action from $ip
   fi

done < <(printf '%s\n' "$ufwvar")


wget -O /tmp/dnsbl.txt https://dnsbl.softsmart.co.za/api/v1/DNS/list?format=text&type=ip --no-check-certificate
echo -e "\n" >> /tmp/dnsbl.txt

if [ -f /tmp/dnsbl.txt ]
then
	#cat /tmp/dnsbl.txt
	#echo ""
	#echo "start loop"

        while read line
        do

        	if [ ! -z "$line" ]
                then
			#echo "line: $line"
			ufw insert 1 deny from ${line} comment 'dnsbl.softsmart.co.za'
		fi
	done </tmp/dnsbl.txt

	#echo "done loop"
	#echo ""

	rm -fr /tmp/dnsbl.txt
fi

