#!/bin/bash

# server_vars.sh

IPv6=`ip addr show | grep "inet6 " | grep "global" | awk 'NR>0{ sub(/\/.*/,"",$2); print $2 }'`
IPv4=`ip addr show | grep "inet " | grep "global" | awk 'NR>0{ sub(/\/.*/,"",$2); print $2 }'`

IPv4=`echo "$IPv4" | xargs`
#IPv4=`echo "\"$IPv4\"" | tr ' ' '","'`
IPv4=`echo "\"$IPv4\""| sed -r 's/[ ]+/","/g'`
IPv6=`echo "$IPv6" | xargs`
IPv6=`echo "\"$IPv6\"" | tr ' ' '","'`

echo "{\"ipv4\":[$IPv4],\"ipv6\":[$IPv6]}"
