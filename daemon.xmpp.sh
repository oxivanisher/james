#!/bin/bash

# README!
# - You have to configure user and password in bot/config/systembot.py
# - You have to install (debian) python-xmpp and screen
#   Optional: mpc, espeak, etherwake

. /opt/james/settings/settings.sh

OLDPWD=$(pwd)

cd $BOTDIR
while true; do
	echo -e "XMPP Daemon starting. Hit ctrl+c for clean shutdown"
	python ./james.py
	echo -e "Press ctrl+c again within the next 10 seconds for definitive shutdown"
	sleep 5
done

cd $OLDPWD
