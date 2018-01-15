#!/bin/bash

Password=`cat /usr/webcp/password`

NextID=$(mysql cpadmin -u root -p${Password} -se "SELECT Uid from Domains order by Uid desc limit 1;")
echo $NextID


