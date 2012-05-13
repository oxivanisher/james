#!/bin/bash

# first element will be spoken, everything will be sent via XMPP

source /opt/james/settings/settings.sh

# message chat headline
echo -e "$@" | /usr/bin/env sendxmpp -r Alert -u $XMPPUSER -p $XMPPPASS -j $XMPPDOMAIN $XMPPTARGET &
/usr/bin/env espeak "$1" >/dev/null 2>&1
echo -e "$(date +%H:%M:%S):\n$1\n\n" >>$ALERTLOG
