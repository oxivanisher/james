#!/bin/bash
# Copied from Steven on http://gentoo-wiki.com/Talk:TIP_Bluetooth_Proximity_Monitor

source /opt/james/settings/settings.sh

function check_pconnection {
    PCONN=0; PFOUND=0
    for s in $(/usr/bin/env hcitool con); do
        if [[ "$s" == "$PINGDEVICEMAC" ]]; then
            PFOUND=1;
        fi
    done
    if [[ $PFOUND == 1 ]]; then
        PCONN=1
    else
        if [ -z $(/usr/bin/env hcitool cc $PINGDEVICEMAC 2>&1) ]; then
            PCONN=1
        else
            if [ -z $(/usr/bin/env l2ping -c 2 $PINGDEVICEMAC 2>&1) ]; then
               if [ -z $(/usr/bin/env hcitool cc $PINGDEVICEMAC 2>&1) ]; then
                   PCONN=1
               fi
            fi
        fi
    fi
    if [ $PCONN == 1 ];
    then
	echo 1
    else
	echo 0
    fi
}

function transfer_file {
	if [ -f "$1" ];
	then
		export RSYNC_PASSWORD=$RSYNCPW
		/usr/bin/env rsync -a $(dirname $1)/* $RSYNCTARGET
		export RSYNC_PASSWORD=""
	fi
}
