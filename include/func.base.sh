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
	chmod +s $BASEDIR/new_event.sh
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

	TARGETHOST=$(detect_host $1)
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

	echo 0 > $TMPDIR/james.check_host_ips.tmp
	echo $IPLIST | while read IP;
	do
		if [ "$(echo $IP | grep $MYIP)" != "" ];
		then
		#	echo "$(hostname) check_host_ips found localhost!" >&2
			echo 1 > $TMPDIR/james.check_host_ips.tmp
		fi
	done

	echo $(cat $TMPDIR/james.check_host_ips.tmp)
	rm $TMPDIR/james.check_host_ips.tmp >/dev/null
}

function detect_host {
#	echo myip: $MYIP
#	echo alerthost: $ALERTHOST
#	MYIP=$(ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}')
	TMPHOST="not_set"
	case "$1" in
		"alert")
			RESULT=$(check_host_ips "$ALERTNODE")
			TMPHOST=$ALERTNODE
		;;
		"rasp")
			RESULT=$(check_host_ips "$RASPNODE")
			TMPHOST=$RASPNODE
		;;
		"proximity")
			RESULT=$(check_host_ips "$PROXIMITYNODE")
			TMPHOST=$PROXIMITYNODE
		;;
		"jabber")
			RESULT=$(check_host_ips "$JABBERNODE")
			TMPHOST=$JABBERNODE
		;;
		*)
			echo "error, no module choosen."
		;;
	esac

#	echo "$(hostname) detect_host result: $RESULT, returning host $TMPHOST" >&2
#
#	if [ $RESULT == "" ];
#	then
#		echo "error_no_host_found"
#	elif [ $RESULT == 1 ];
#	then
#		echo "localhost"
#	else
#		echo "$(host $TMPHOST | awk '{ print $1 }' | uniq)"
#	fi
	
	if [ $TMPHOST == "" ];
	then
		echo "error_no_host_found"
	elif [ $TMPHOST == $(hostname) ];
	then
		echo "localhost"
	else
		echo "$(host $TMPHOST | awk '{ print $1 }' | uniq)"
	fi

}
