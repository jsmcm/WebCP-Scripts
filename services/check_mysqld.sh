#! /bin/bash

export DISPLAY=:0.0
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/root/bin
HOME=/root

source $HOME/.profile




Var=`service mysql status`

if [[ "$Var" =~ "running" ]]
then
        echo "running..."
        service mysql stop
fi


