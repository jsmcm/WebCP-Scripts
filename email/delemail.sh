#!/bin/bash

x=$(pgrep delemail.sh | wc -w)
if [ $x -gt 2 ]; then
        exit
fi


Password=`/usr/webcp/get_password.sh`

for FullFileName in /var/www/html/webcp/nm/*.dma; 
do

	if [ -f $FullFileName ]
	then	

                echo $FullFileName
                x=$FullFileName
                y=${x%.dma}
                UserName=${y##*/}
                UserName=${UserName%_*}
                #DomainName=$(mysql cpadmin -u root -p${Password} -se "SELECT fqdn FROM domains WHERE deleted = 0 AND UserName = '$UserName' AND domain_type = 'primary';")
                GroupID=$(mysql cpadmin -u root -p${Password} -se "SELECT Gid FROM domains WHERE deleted = 0 AND UserName = '$UserName' AND domain_type = 'primary';")
                UserID=$(mysql cpadmin -u root -p${Password} -se "SELECT Uid FROM domains WHERE deleted = 0 AND UserName = '$UserName' AND domain_type = 'primary';")

		Dir=`cat $FullFileName`
		
		DomainName=${Dir%/*}
                echo "domain: $DomainName"

                DomainName=${DomainName##*/}
                echo "domain: $DomainName"



                echo "DomainName: $DomainName"
                echo "UserName: $UserName"
                echo "Guid: $GroupID"
                echo "Uid: $UserID"
	
		
                /usr/webcp/email/mkpasswdfiles.sh $DomainName $UserName $GroupID $UserID                         




		if [ "${#Dir}" -gt "5" ]
		then
		        rm -fr $Dir		
		fi
		rm -fr $FullFileName
	fi
	

done

