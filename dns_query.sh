#!/bin/bash

Name=$1

out=`dig +short $Name`

if [ "$out" == "" ]
then
	echo 0
else
	echo 1
fi

