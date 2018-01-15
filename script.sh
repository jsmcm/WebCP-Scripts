#!/bin/bash
Password=`cat /usr/webcp/password`

for FullFileName in /var/www/html/webcp/nm/*.delete_single_filters;
do

        if [ -f $FullFileName ]
        then
                #echo $FullFileName
                x=$FullFileName
                #echo "x: '$x'"
                y=${x%.delete_single_filters}
                #echo "y: '$y'"
                ClientID=${y##*/}
                echo "file: '$ClientID'"

		mysql cpadmin -u root -p${Password} -N -e "SELECT UserName, fqdn FROM domains WHERE deleted = 0  AND client_id = $ClientID" | while read UserName fqdn; do
		    echo "rm -f /home/$UserName/mail/$fqdn/.filter"
		done

		rm -fr $FullFileName
	fi
done

