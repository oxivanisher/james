#!/bin/bash
source /opt/james/settings/settings.sh
source $BASEDIR/include/func.*.sh

OLDPWD=$(pwd)

cd $BOTDIR
while true; do
    echo -e "RaspBerry Pi Daemon starting. Hit ctrl+c for a clean shutdown."
    $(which php) ./james.rasp.php
    echo -e "Press ctrl+c again within the next 5 seconds for definitive shutdown."
    sleep 5
done

