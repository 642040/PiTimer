#!/bin/bash

# Copyright (C) 2013 Alwyn Peter Allan

LOG_PATH=/var/log   # writable to user calling this script
EMAIL=adrian@azallans.com                        # as registered with PowerNag.com
FUNCTION=PiTimer                     # as registered with Powernag.com

# Be sure that this script is executable, e.g. '$ chmod +x powernag_report_present.sh'
# Maybe use '$ crontab -e' to add a line calling this script, e.g.
#                    '0,10,20,30,40,50 * * * * /usr/local/bin/powernag_report_present.sh'
# Or have it called by rsnapshot by enabling this in /etc/rsnapshot.conf:
#                    'cmd_postexec    /usr/local/bin/powernag_report_present.sh'

export PATH=/usr/bin:/bin
cd $LOG_PATH
SCRIPT=`basename $0`
LOG=`basename $SCRIPT .sh`.log

# This delays the first request a different amount for each machine. It helps
# even the load on our servers. Pre-calculate $DELAY if you like, but use it.
((DELAY=`ls /dev/disk/by-uuid|cksum|cut -d' ' -f1`%60))
sleep $DELAY

TRIES=0
RESULT=1
until [ $RESULT -eq 0 ] || [ $TRIES -ge 3 ]
do
  if [ $TRIES -gt 0 ]; then sleep 25; fi
  OUTPUT=`wget -O - -q \
          --post-data="request=present&email=$EMAIL&function=$FUNCTION" \
          http://PowerNag.com/api`
  RESULT=$?
  (( TRIES++ ))
  if [ $RESULT -ne 0 ] || [ "$OUTPUT" != "OK." ]; then
    echo "$(date) $SCRIPT: result '$RESULT' output '$OUTPUT' tries '$TRIES'" \
         >> $LOG
  fi
done
exit 0
