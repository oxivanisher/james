#!/bin/bash
source /opt/james/settings/settings.sh
source $BASEDIR/include/func.proximity.sh

function check_files {
    ERROR=""
    CFGFILES="settings/james.cfg\
        settings/settings.sh"

    EXTFILES="ntpdate-debian\
        python\
        hcitool\
        l2ping\
        rsync\
        nmap\
        etherwake\
        arp-scan\
        sendxmpp\
        espeak\
        php\
        motion\
        screen"

    for FILE in $EXTFILES;
    do
        if [ -n "$(which $FILE)" ];
        then
            continue
        fi
        ERROR="$FILE"
        break
    done

    for FILE in $CFGFILES;
    do
        if [ -f "$BASEDIR/$FILE" ];
        then
            continue
        fi
        ERROR="$FILE"
        break
    done

    if [ "a$ERROR" == "a" ];
    then
        return 0
    else
        echo -e "$ERROR not found!"
        return 1
    fi
}

function start_daemons {
    echo -e -n "\tChecking daemons: "
    if [ "$(/usr/bin/env screen -ls | grep proximity-daemon)a" == "a" ];
    then
        echo -e -n "proximity-daemon ";
        /usr/bin/env screen -dmS proximity-daemon $BASEDIR/daemon.proximity.sh
    fi

    if [ "$(/usr/bin/env screen -ls | grep xmpp-daemon)a" == "a" ];
    then
        echo -e -n "xmpp-daemon ";
        /usr/bin/env screen -dmS xmpp-daemon $BASEDIR/daemon.xmpp.sh &
    fi
    echo -e "> done"
}

function wait_for_lock {
    #FIXME to be done!
    true
}

function alert {
    $ALERT $@
}