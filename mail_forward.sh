#!/bin/bash
Password=`cat /usr/webcp/password`


for FullFileName in /var/www/html/webcp/nm/*.delete_single_forwards;
do

        if [ -f $FullFileName ]
        then
                #echo $FullFileName
                x=$FullFileName
                #echo "x: '$x'"
                y=${x%.delete_single_forwards}
                #echo "y: '$y'"
                ClientID=${y##*/}
                echo "file: '$ClientID'"

                mysql cpadmin -u root -p${Password} -N -e "SELECT UserName, fqdn FROM domains WHERE deleted = 0  AND client_id = $ClientID" | while read UserName fqdn; do

                    if [ "${#UserName}" -gt "4" ]
                    then
			rm -f /home/$UserName/mail/$fqdn/.forward
		    fi

                done

        fi
done



for FileName in /var/www/html/webcp/nm/*.singleforward;
do

        if [ -f $FileName ]
        then


                ActualPath=${FileName##*/}
					
		ActualPath=$(echo $ActualPath | tr '_' '/')
		ActualPath=${ActualPath/.singleforward/.forward}

		echo "mv $FileName $ActualPath"
		mv $FileName $ActualPath
		rm -fr $FileName
	fi
done




for FullFileName in /var/www/html/webcp/nm/*.delete_single_forwards;
do

        if [ -f $FullFileName ]
        then
                #echo $FullFileName
                x=$FullFileName
                #echo "x: '$x'"
                y=${x%.delete_single_forwards}
                #echo "y: '$y'"
                ClientID=${y##*/}
                echo "file: '$ClientID'"

                mysql cpadmin -u root -p${Password} -N -e "SELECT UserName, fqdn FROM domains WHERE deleted = 0  AND client_id = $ClientID" | while read UserName fqdn; do
                    	if [ "${#UserName}" -gt "1" ]
			then
				chown $UserName.$UserName /home/$UserName/mail/$fqdn/.forward
		   		chmod 755 /home/$UserName/mail/$fqdn/.forward
			fi
                done

                rm -fr $FullFileName
        fi
done

