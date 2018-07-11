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

		if [ -f /var/cache/bind/slaves/$file ]
		then
			if [ ! -z $file ]
			then
				rm -fr /var/cache/bind/slaves/$file
			fi
		fi

		mv $FullFileName /var/cache/bind/slaves/$file
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

                if [ -f /var/cache/bind/slaves/$file ]
                then
                        if [ ! -z $file ]
                        then
                                rm -fr /var/cache/bind/slaves/$file
                        fi
                fi
		
		rm -fr $FullFileName
        fi

        echo "Looping"

done



if [ -f "/var/www/html/webcp/nm/named.conf.local" ]
then

	if [ -f /etc/bind/named.conf.local ]
	then
		rm -fr /etc/bind/named.conf.local
	fi

	echo "moving conf"
	mv /var/www/html/webcp/nm/named.conf.local /etc/bind/named.conf.local

	RESTART=1
fi

if [ -f "/var/www/html/webcp/nm/named.conf.options" ]
then

	if [ -f /etc/bind/named.conf.options ]
	then
		rm -fr /etc/bind/named.conf.options
	fi

	echo "moving conf"
	mv /var/www/html/webcp/nm/named.conf.options /etc/bind/named.conf.options

	RESTART=1
fi



if [ $RESTART == 1 ]
then
	echo "restarting"
	/usr/sbin/rndc reload
fi
