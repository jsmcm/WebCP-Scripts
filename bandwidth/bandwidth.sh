#!/bin/bash

x=$(pgrep bandwidth.sh | wc -w)
if [ $x -gt 2 ]; then
        exit
fi

/usr/webcp/bandwidth/exim.sh
/usr/webcp/bandwidth/dovecot.sh
/usr/webcp/bandwidth/ftp.sh
/usr/webcp/bandwidth/awstats.sh
/usr/webcp/bandwidth/usr_bw.sh
/usr/webcp/bandwidth/usr_du.sh
