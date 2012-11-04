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
        screen\
		host\
		ip"

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

function check_host_ips {
	IPLIST=$(host $1 | awk '{ print $4 }')
	MYIP=$(ip addr show | grep inet | grep -v "127.0.0.1/8" | awk '{ print $2}' | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}')

	TMPBOOL=0
	echo $IPLIST | while read IP;
	do
		if [ "$(echo $IP | grep $MYIP)" != "" ];
		then
			TMPBOOL=1
		fi
	done

	#1 means localhost
	if [ $TMPBOOL -gt 0 ];
	then
		echo 1
	else
		echo 0
	fi
}

function detect_host {
#	echo myip: $MYIP
#	echo alerthost: $ALERTHOST
#	MYIP=$(ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}')
	case "$1" in
		"alert")
			RESULT=$(check_host_ips "$ALERTHOST")
			TMPHOST=$ALERTHOST
		;;
		"rasp")
			RESULT=$(check_host_ips "$RASPHOST")
			TMPHOST=$RASP
		;;
		*)
			echo -1
		;;
	esac

#	echo "result: $RESULT --"
	if [ $RESULT == 1 ];
	then
		echo "localhost"
	else
		echo "$(host $TMPHOST | awk '{ print $1 }')"
	fi

}
