#!/bin/bash

function removeDuplicates() {

	username=$1

	mounts=`mount | grep $username\/bin`
	echo "pre mounts: $mounts"
	count=`echo "$mounts" | wc -l`
	echo "pre count: $count"

	while [ $count -gt 1 ]
	do

		/usr/webcp/domains/unmount.sh "$username"

		mounts=`mount | grep $username\/bin`
		echo "loop mounts: $mounts"
		count=`echo "$mounts" | wc -l`
		echo "loop count: $count"

	done

	mounts=`mount | grep $username\/bin`

	echo "$mounts" | wc -l
	echo ""
	echo "mounts: $mounts"
}

for d in /home/*/
do
        y=${d%/}
	domain=${y##*/}

	echo "==================="
        echo "check director: $domain"
	echo ""


	removeDuplicates "$domain"
done


