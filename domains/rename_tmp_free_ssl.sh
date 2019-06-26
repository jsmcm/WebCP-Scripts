#!/bin/bash

x=$(pgrep rename_tmp_free_ssl.sh | wc -w)
if [ $x -gt 2 ]; then
        exit
fi

for FullFileName in /var/www/html/webcp/nm/*.freessl_tmp; 
do

	x=$FullFileName
        y=${x%_tmp}
        mv $FullFileName $y

done




