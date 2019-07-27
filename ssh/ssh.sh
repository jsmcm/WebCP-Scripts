#!/bin/bash

x=$(pgrep ssh.sh | wc -w)
if [ $x -gt 2 ]; then
        exit
fi


/usr/webcp/ssh/add_ssh.sh
/usr/webcp/ssh/delete_ssh.sh
/usr/webcp/ssh/authorise.sh
