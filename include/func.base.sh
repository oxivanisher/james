#!/bin/bash
source /opt/james/settings/settings.sh
source $BASEDIR/include/func.proximity.sh

function check_files {
    ERROR=""
    CFGFILES="settings/james.cfg\
        settings/settings.sh\
		settings/settings.php"

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

	chown root $BASEDIR/new_event.sh
	chmod 755 $BASEDIR/new_event.sh
	chmod +s $BASEDIR/new_event.sh
}

function start_daemon {
    if [ -f "$BASEDIR/daemon.$1.sh" ];
    then
        if [ "$($(which screen) -ls | grep james-$1-daemon)a" == "a" ];
        then
            echo -e -n "$1 ";
            $(which screen) -dmS james-$1-daemon $BASEDIR/daemon.$1.sh
        fi
    fi
}

function wait_for_lock {
    #FIXME to be done!
    true
}

function alert {
    if [ -n "$1" ];
    then
        LOOP=1
        while [ $LOOP -eq 1 ];
        do
            if [ -f "$ALERTMESSAGES.lock" ];
            then
                sleep 1
                LOOP=1
            else
                echo "\"$1\" \"$2\"" >> $ALERTMESSAGES
                LOOP=0
            fi
        done
    fi
}

function detect_host {
	MYIP=$(ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}')
	case "$1" in
		"alert")
			if [ "a$MYIP" == "a$ALERTHOST" ];
			then
				echo "localhost"
			else
				echo "$ALERTHOST"
			fi
		;;
		*)
			echo "error_module_not_found"
		;;
	esac

}
