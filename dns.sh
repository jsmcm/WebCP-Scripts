#!/bin/bash

x=$(pgrep dns.sh | wc -w)
if [ $x -gt 2 ]; then
        exit
fi

RESTART=0

for FullFileName in /var/www/html/webcp/nm/*.dnsadd; 
do

	if [ -f $FullFileName ]
	then	
		echo $FullFileName
		x=$FullFileName
                echo "x: '$x'"
		y=${x%.dnsadd}
                echo "y: '$y'"
		file=${y##*/}
                echo "file: '$file'"

		if [ -f /var/named/slaves/$file ]
		then
			if [ ! -z $file ]
			then
				rm -fr /var/named/slaves/$file
			fi
		fi

		mv $FullFileName /var/named/slaves/$file
		RESTART=1
	fi

	echo "Looping"

done



for FullFileName in /var/www/html/webcp/nm/*.dnsdel;
do

        if [ -f $FullFileName ]
        then
                echo $FullFileName
                x=$FullFileName
                echo "x: '$x'"
                y=${x%.dnsdel}
                echo "y: '$y'"
                file=${y##*/}
                echo "file: '$file'"

                if [ -f /var/named/slaves/$file ]
                then
                        if [ ! -z $file ]
                        then
                                rm -fr /var/named/slaves/$file
                        fi
                fi
		
		rm -fr $FullFileName
        fi

        echo "Looping"

done



if [ -f "/var/www/html/webcp/nm/named.conf" ]
then

	if [ -f /etc/named.conf ]
	then
		rm -fr /etc/named.conf
	fi

	echo "moving conf"
	mv /var/www/html/webcp/nm/named.conf /etc/named.conf

	RESTART=1
fi


if [ $RESTART == 1 ]
then
	echo "restarting"
	/usr/sbin/rndc reload
fi
