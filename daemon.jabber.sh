#!/bin/bash
source /opt/james/settings/settings.sh
source $BASEDIR/include/func.*.sh

OLDPWD=$(pwd)

cd $BOTDIR
while true; do
    echo -e "XMPP Daemon starting. Hit ctrl+c for clean shutdown"
	alert "Sir James at your service Sire."
    $(which python) ./james.jabber.py
    echo -e "Press ctrl+c again within the next 10 seconds for definitive shutdown"
    sleep 5
done

cd $OLDPWD
