#!/bin/bash
source /opt/james/settings/settings.sh
source $BASEDIR/include/func.proximity.sh

function check_files {
    ERROR=""
    CFGFILES="settings/settings.sh\
		settings/settings.php"

    EXTFILES="php\
        screen\
		host\
		ip"

    for FILE in $EXTFILES;
    do
        if [ -n "$(which $FILE)" ];
        then
            continue
        fi
        ERROR="$ERROR $FILE"
        break
    done

    for FILE in $CFGFILES;
    do
        if [ -f "$BASEDIR/$FILE" ];
        then
            continue
        fi
        ERROR="$ERROR $FILE"
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
	chmod u+s $BASEDIR/new_event.sh
	echo "" > $PSTATEFILE
}

function start_daemon {
	#extfiles
	# jabber: python nmap
    # proximity: hcitool l2ping rsync nmap arp-scan etherwake motion 
	# whoisonline: nbtscan
	# alert: sendxmpp espeak

	#cfgfiles
	# jabber: settings/james.cfg

	TARGETHOST=$(get_node_name $1)
	if [ "$TARGETHOST" == "localhost" ];
    then
		if [ -f "$BASEDIR/daemon.$1.sh" ];
	    then
	        if [ "$($(which screen) -ls | grep james-$1-daemon)a" == "a" ];
	        then
	            echo -e -n "$1 ";
	            $(which screen) -dmS james-$1-daemon $BASEDIR/daemon.$1.sh
			fi
	    fi
    fi
}

function start_all_daemons {
	start_daemon jabber
	start_daemon alert
	start_daemon proximity
	start_daemon rasp
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

function get_node_name {
	case "$1" in
		"alert")
			TMPHOST=$ALERTNODE
		;;
		"rasp")
			TMPHOST=$RASPNODE
		;;
		"proximity")
			TMPHOST=$PROXIMITYNODE
		;;
		"jabber")
			TMPHOST=$JABBERNODE
		;;
		*)
			TMPHOST="module_found_$1"
		;;
	esac

	if [ $TMPHOST == $(hostname) ];
	then
		echo "localhost"
	else
		echo $TMPHOST
	fi

}
