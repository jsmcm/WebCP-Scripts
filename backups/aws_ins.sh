#!/bin/bash

LocalFile=$1
RemotePath=$2
Type=$3
Count=$4

re='^[0-9]+$'
if ! [[ $Count =~ $re ]] ; then
   echo "error: Not a number"
        Count=1
fi

if [ $Count -gt 65 ]
then
        Count=65
fi

x=$LocalFile
y=${x%.nma}
file=${y##*/}
FileName=${file%_*}

DeleteFile=$Count
((DeleteFile--))

if [ $DeleteFile -gt 0 ]
then

     #echo "/usr/local/bin/aws s3 rm s3://${RemotePath}/${Type}_${FileName}.$DeleteFile"
     /usr/local/bin/aws s3 rm s3://${RemotePath}/${Type}_${FileName}.$DeleteFile > /dev/null
	
fi



for (( Rename=$DeleteFile; Rename>0; Rename-- ))
do
	Temp=$Rename
	((Temp--))

	TempFile=".$Temp"
	if [ $Temp -eq 0 ]
	then
		TempFile=""
	fi

	
	
	#echo "/usr/local/bin/aws s3 mv s3://${RemotePath}/${Type}_${FileName}$TempFile s3://${RemotePath}/${Type}_${FileName}.$Rename"
	/usr/local/bin/aws s3 mv s3://${RemotePath}/${Type}_${FileName}$TempFile s3://${RemotePath}/${Type}_${FileName}.$Rename > /dev/null
done

/usr/local/bin/aws s3 cp ${LocalFile} s3://${RemotePath}/${Type}_${FileName} # &2>1
#echo "/usr/local/bin/aws s3 cp ${LocalFile} s3://${RemotePath}/${Type}_${FileName}"



