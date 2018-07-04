#!/bin/bash

x=$(pgrep check_quota.sh | wc -w)
if [ $x -gt 2 ]; then
        exit
fi

if [ ! -d "/var/www/html/webcp/quota/quota_files" ]; then
	mkdir -p /var/www/html/webcp/quota/quota_files
fi

for FullFileName in /var/www/html/webcp/quota/quota_files/*.uquota;
do
        if [ -f $FullFileName ]
        then
                rm -fr $FullFileName
        fi
done


for FullFileName in /home/*; 
do

        if [ -d $FullFileName ]
        then
                
		if [ -d "$FullFileName/public_html" ]
		then
			x=$FullFileName
        	        UserName=${x##*/}
			DiskUsageone=`du -chs /home/$UserName`
			echo $DiskUsageone > /var/www/html/webcp/quota/quota_files/$UserName.uquota
		fi
        fi

done

