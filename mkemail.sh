#!/bin/bash

x=$(pgrep mkemail.sh | wc -w)
if [ $x -gt 2 ]; then
        exit
fi

for FullFileName in /var/www/html/webcp/nm/*.nma; 
do

	if [ -f $FullFileName ]
	then	

		echo $FullFileName
		x=$FullFileName
		y=${x%.nma}
		file=${y##*/}
               file=${file%_*}
		echo "file: $file"
	
		Dir=`cat $FullFileName`
		echo $Dir
	
		if [ "${#Dir}" -gt "4" ]
		then
			echo "mkdir $Dir -p"
			mkdir $Dir -p
	
			echo "chmod 755 $Dir -R"
			chmod 755 $Dir -R
	
			echo "chown $file.$file $Dir -R"
			chown $file.$file $Dir -R
				
			
			echo "mkdir $Dir/cur"
			mkdir $Dir/cur
	
			echo "chmod 755 $Dir/cur -R"
			chmod 755 $Dir/cur -R
	
	
			echo "chown $file.$file $Dir/cur -R"
			chown $file.$file $Dir/cur -R
			
			echo "mkdir $Dir/new"
			mkdir $Dir/new
	
			echo "chmod 755 $Dir/new -R"
			chmod 755 $Dir/new -R
	
			echo "chown $file.$file $Dir/new -R"
			chown $file.$file $Dir/new -R
	
			rm -fr $FullFileName
		fi
	fi
	

done

