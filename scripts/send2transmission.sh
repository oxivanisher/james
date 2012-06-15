#!/bin/bash
source /opt/james/settings/settings.sh

# based on http://blog.flo.cx/2011/02/how-to-open-magnet-links-on-a-remote-transmission-daemon-with-one-click/
#test -z $1 && echo "need torrent/magnet link!" && exit -1
 
LINK="$@"
# set true if you want every torrent to be paused initially
#PAUSED="true"
PAUSED="false"
SESSID=$(curl --silent --anyauth --user $TRUSER:$TRPASS "http://$TRHOST:$TRPORT/transmission/rpc" | sed 's/.*<code>//g;s/<\/code>.*//g')
if [ "a" == "a$LINK" ];
then
	RETURN=$(curl --silent --anyauth --user $TRUSER:$TRPASS --header "$SESSID" "http://$TRHOST:$TRPORT/transmission/rpc" -d "{\"method\":\"session-stats\"}")
	echo $RETURN
else
	RETURN=$(curl --silent --anyauth --user $TRUSER:$TRPASS --header "$SESSID" "http://$TRHOST:$TRPORT/transmission/rpc" -d "{\"method\":\"torrent-add\",\"arguments\":{\"paused\":${PAUSED},\"filename\":\"${LINK}\"}}")
	CHECK=$(echo $RETURN | grep -v '"result":"success"')
	
	if [ "a" == "a$CHECK" ];
	then
		/opt/james/new_event.sh alert "Download started." &
		echo -n -e "Success!"
	else
		echo -n -e "ERROR: $RETURN"
	fi
fi


