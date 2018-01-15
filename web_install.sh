#!/bin/bash

echo "In web_install.sh"
if [ $(pgrep web_install.sh| wc -w) -gt 2 ]; then
	echo "already running"
        exit
fi


	for FullFileName in /var/www/html/webcp/nm/*.wp;
	do

	        if [ -f $FullFileName ]
	        then

	                echo $FullFileName

			SkipFile="false"
			DomainUsername=""
			DatabaseName=""
			DatabaseUsername=""
			DatabasePassword=""
			Path=""
		
			oldIFS="$IFS"
			IFS=":"
			while read name value
			do
				# Check value for sanity?  Name too?
	 			eval $name="$value"
			done < $FullFileName
			IFS="$oldIFS"



			if [ -z $DomainUsername ]
			then
				SkipFile="true"
			fi

			if [ -z $DatabaseUsername ]
			then
				SkipFile="true"
			fi

			if [ -z $DatabaseName ]
			then
				SkipFile="true"
			fi

			if [ -z $DatabasePassword ]
			then
				SkipFile="true"
			fi

			if [ -z $Path ]
			then
				SkipFile="true"
			fi

		
			if [ "$SkipFile" == "false" ]
			then
			
				/usr/webcp/wp_auto_install.sh $DomainUsername $DatabaseName $DatabaseUsername $DatabasePassword $FullFileName $Path
			else 
				if [ "${#FullFileName}" -gt "15" ]				
				then
					rm -fr $FullFileName
				fi
			fi
		fi


	done

