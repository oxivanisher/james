#!/bin/bash

. /opt/james/settings/settings.sh

bool=true
REST=""

for var in "$@"
do
	if [ "$bool" = "true" ];
	then
		bool=false
	else
		REST="$REST $(echo $var | sed 's/!/\!/')"
#		REST="$REST $var"
	fi
done

MYCMDS='mpc volume -30;
	sleep 1;
	echo "Attention please:'

MYCMDE='" | espeak;
	sleep 1;
	mpc volume +30'

echo $MYCMDS$REST$MYCMDE | at "$1" 2>&1 | tail -n 1

echo -e "Message:$REST"
