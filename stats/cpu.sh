#!/bin/bash
# by Paul Colby (http://colby.id.au), no rights reserved ;)




PREV_TOTAL=0
PREV_IDLE=0

  CPU=(`cat /proc/stat | grep '^cpu '`) # Get the total CPU statistics.
  unset CPU[0]                          # Discard the "cpu" prefix.
  IDLE=${CPU[4]}                        # Get the idle CPU time.

  # Calculate the total CPU time.
  TOTAL=0

  for VALUE in "${CPU[@]:0:4}"; do
    let "TOTAL=$TOTAL+$VALUE"
  done

  # Calculate the CPU usage since we last checked.
  let "DIFF_IDLE=$IDLE-$PREV_IDLE"
  let "DIFF_TOTAL=$TOTAL-$PREV_TOTAL"
  let "DIFF_USAGE=(1000*($DIFF_TOTAL-$DIFF_IDLE)/$DIFF_TOTAL+5)/10"

  # Remember the total and idle CPU times for the next check.
  PREV_TOTAL="$TOTAL"
  PREV_IDLE="$IDLE"


  CPU=(`cat /proc/stat | grep '^cpu '`) # Get the total CPU statistics.
  unset CPU[0]                          # Discard the "cpu" prefix.
  IDLE=${CPU[4]}                        # Get the idle CPU time.

  # Calculate the total CPU time.
  TOTAL=0


  for VALUE in "${CPU[@]:0:4}"; do
    let "TOTAL=$TOTAL+$VALUE"
  done

  # Calculate the CPU usage since we last checked.
  let "DIFF_IDLE=$IDLE-$PREV_IDLE"
  let "DIFF_TOTAL=$TOTAL-$PREV_TOTAL"
  
  let "DIFF_USAGE=(1000*($DIFF_TOTAL-$DIFF_IDLE)/($DIFF_TOTAL+5))/10"

  echo "$DIFF_USAGE" >> /tmp/webcp/cpu.stat

lineCount=0
temp=0
total=0

if [ -f /tmp/webcp/cpu.stat ]
then
        while read line
        do
                ((lineCount++))
                let temp=$line
                let total=$total+$temp

        done</tmp/webcp/cpu.stat
	
	if [ $lineCount == 10 ]
	then
	
		let average=$total/10
	
		Password=`/usr/webcp/get_password.sh`
		User=`/usr/webcp/get_username.sh`
		DB_HOST=`/usr/webcp/get_db_host.sh`

		DATE=$(date +"%Y-%m-%d %H:%M:%S")
		
		$(mysql cpadmin -u ${User} -p${Password} -h ${DB_HOST} -se "INSERT INTO server_stats VALUES (0, 'cpu', 0, '$average', 0, '$DATE', 0);")
	
		rm -fr /tmp/webcp/cpu.stat
	fi

fi
