#!/bin/bash
# Copied from Steven on http://gentoo-wiki.com/Talk:TIP_Bluetooth_Proximity_Monitor

. /opt/james/settings/settings.sh

function check_pconnection {
    PCONN=0; PFOUND=0
    for s in `$HCITOOL con`; do
        if [[ "$s" == "$DEVICE" ]]; then
            PFOUND=1;
        fi
    done
    if [[ $PFOUND == 1 ]]; then
        PCONN=1
    else
        if [ -z "`$HCITOOL cc $DEVICE 2>&1`" ]; then
            PCONN=1
        else
            if [ -z "`l2ping -c 2 $DEVICE 2>&1`" ]; then
               if [ -z "`$HCITOOL cc $DEVICE 2>&1`" ]; then
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
		$RSYNCPATH -a $(dirname $1)/* $RSYNCCMD
		export RSYNC_PASSWORD=""
	fi
}
