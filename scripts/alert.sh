#!/bin/bash
source /opt/james/settings/settings.sh

# first element will be spoken, everything will be sent via XMPP

# message chat headline
MSG=$1
if [ "a$2" != "a" ];
then
    MSG="$1\n$2"
fi

MSG=$(echo $MSG | sed 's/"//g')

if [ $(cat $PSTATEFILE) -eq 1 ];
then
    $(which espeak) -v en-rp -ven+m7  "$1" >/dev/null 2>&1
else
	echo -e "At $(date +%H:%M): $1" >> $ALERTCACHE
	echo -e "$MSG" | $(which sendxmpp) -r Alert -u $XMPPUSER -p $XMPPPASS -j $XMPPDOMAIN $XMPPTARGET >/dev/null 2>&1 &

fi

echo -e "$(date +%H:%M:%S):\n$1\n\n" >>$ALERTLOG
