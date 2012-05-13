#!/bin/bash
source /opt/james/settings/settings.sh

# first element will be spoken, everything will be sent via XMPP

# message chat headline
echo -e "$@" | /usr/bin/env sendxmpp -r Alert -u $XMPPUSER -p $XMPPPASS -j $XMPPDOMAIN $XMPPTARGET >/dev/null 2>&1 &
/usr/bin/env espeak "$1" >/dev/null 2>&1
echo -e "$(date +%H:%M:%S):\n$1\n\n" >>$ALERTLOG
