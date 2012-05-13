#!/bin/bash

# first element sould be the message (yes, i am currently lazy)

source /opt/james/settings/settings.sh

# message chat headline
echo -e "$@" | sendxmpp -r Alert -u $AUSER -p $APASS -j $ADOMAIN $ATARGET &
$SPKAGENT "$1" >/dev/null 2>&1
echo -e "$(date +%H:%M:%S):\n$1\n\n" >>$ALOG
