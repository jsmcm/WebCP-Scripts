#!/bin/bash

for FileName in /var/www/html/webcp/nm/*.autoreply;
do

	echo "Checking $FileName"

        if [ -f $FileName ]
        then

		
                ActualPath=${FileName##*/}
					
		ActualPath=$(echo $ActualPath | tr '_' '/')
		ActualPath=${ActualPath/.autoreply/.msg}

		echo "mv $FileName $ActualPath"
		mv $FileName $ActualPath
	fi
done
