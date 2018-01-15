#!/bin/bash

if [ $(pgrep f2b_jobs.sh| wc -w) -gt 2 ]; then
        exit
fi

	/usr/webcp/csf_remove_ban.sh
	/usr/webcp/csf_add_ban.sh
	/usr/webcp/csf_perm.sh
