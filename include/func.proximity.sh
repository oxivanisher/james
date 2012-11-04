#!/bin/bash
. /opt/james/settings/settings.sh

function check_pconnection {
    PCONN=0; PFOUND=0
    for s in "$($(which hcitool) con)"; do
        if [[ "$s" == "$PINGDEVICEMAC" ]]; then
            PFOUND=1;
        fi
    done
    if [[ $PFOUND == 1 ]]; then
        PCONN=1
    else
        if [ -z "$($(which hcitool) cc $PINGDEVICEMAC 2>&1)" ]; then
            PCONN=1
        else
            if [ -z "$($(which l2ping) -c 2 $PINGDEVICEMAC 2>&1)" ]; then
               if [ -z "$($(which hcitool) cc $PINGDEVICEMAC 2>&1)" ]; then
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
        $(which rsync) -a $(dirname $1)/* $RSYNCTARGET
        export RSYNC_PASSWORD=""
    fi
}

function is_at_home {
	cat $PSTATEFILE
}
