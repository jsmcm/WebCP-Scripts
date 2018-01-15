#!/bin/bash

IP=$1
Ports=$2
Password=`cat /usr/webcp/password`

$(mysql cpadmin -u root -p${Password} -se "DELETE FROM csf WHERE ip = '$IP';")

