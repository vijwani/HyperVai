#!/bin/bash
SITE=$1
SITE_OK_STATUS=("200")
#Email users
NOTIFY_FROM_EMAIL='monitoring@healthcheck.com'
NOTIFY_TO_EMAIL='anmol7209@gmail.com'
RESPONSE=$(wget $SITE --no-check-certificate -S -q -O - 2>&1 | awk '/^  HTTP/{print $2}')
if [ -z "$RESPONSE" ]; then
    RESPONSE="0"
fi
if [[ $RESPONSE = *$SITE_OK_STATUS* ]]; then
    RESPONSE="200"
    STATUS="UP"
else
    STATUS="DOWN"
fi
echo "Site: $SITE is $STATUS"
echo "Site: $SITE" >>/tmp/SiteMonitor.email.tmp
echo "Status: $STATUS" >>/tmp/SiteMonitor.email.tmp
echo "-----Begin: Sending Email Content for Site status--------"
cat /tmp/SiteMonitor.email.tmp
$(mail -a "From: $NOTIFY_FROM_EMAIL" \
    -s "SiteMonitor Notification: $HOST is $STATUS" \
    "$NOTIFY_TO_EMAIL" </tmp/SiteMonitor.email.tmp)
echo "----- End:  Sending Email Content for Site status--------"