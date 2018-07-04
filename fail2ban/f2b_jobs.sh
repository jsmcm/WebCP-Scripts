#!/bin/bash

if [ $(pgrep f2b_jobs.sh| wc -w) -gt 2 ]; then
        exit
fi

/usr/webcp/fail2ban/f2b_remove_ban.sh
/usr/webcp/fail2ban/f2b_add_ban.sh
