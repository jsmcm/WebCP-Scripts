#!/bin/bash

LocalFile=$1
RemotePath=$2
Host=$3
UserName=$4
Password=$5
Type=$6
Count=$7

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
echo "ftp -n -v $Host"

ftp -n -v $Host <<End-Of-DeleteFile
user $UserName $Password
binary
	
del ${RemotePath}${Type}_${FileName}.$DeleteFile
	
close
quit
End-Of-DeleteFile
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

	
ftp -n -v $Host << End-Of-RenameFile
user $UserName $Password
binary
	
rename ${RemotePath}${Type}_${FileName}$TempFile ${RemotePath}${Type}_${FileName}.$Rename

close
quit
End-Of-RenameFile

done


ftp -n -v $Host << End-Of-PutFile
user $UserName $Password
binary
	
put ${LocalFile} ${RemotePath}${Type}_${FileName}
close
quit
End-Of-PutFile


