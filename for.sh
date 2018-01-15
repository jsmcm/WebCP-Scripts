#!/bin/bash

if [ $(pidof -x for.sh| wc -w) -gt 2 ]; then 
    exit
fi


for n in {1..15}
do
	echo "ho"
	sleep 1
done

