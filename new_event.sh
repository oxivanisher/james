#!/bin/bash
PATH=$PATH:/sbin/
source /opt/james/settings/settings.sh
source $BASEDIR/include/func.*.sh

if [ -f $PSTATEFILE ];
then
    PSTATE=$(cat $PSTATEFILE)
else
    echo 0 > $PSTATEFILE
fi

case "$1" in
    ## System events
    sys_reboot)
        $BASEDIR/new_event.sh alert "$(hostname) is rebooting" ""
        reboot &
    ;;

    sys_poweroff)
        $BASEDIR/new_event.sh alert "$(hostname) is powering down" ""
        poweroff &
    ;;

    sys_startup|start)
        echo -e "James: Your Buttler startup"
        echo -e -n "\tChecking for needed files: "
        check_files || exit 1
        echo -e "> done"

        if [[ ! -d "$MOTIONDIR" ]];
        then
            echo -e "\tCreating tmp directory"
            mkdir -p $MOTIONDIR
        fi
        chmod 777 $MOTIONDIR

        echo -e -n "\tChecking daemons: "
		start_all_daemons
        echo -e "> done"

        echo -e "\t=> Everything is running now\n"
        exit 0
    ;;

    periodic)
        $WHOISONLINE >/dev/null 2>&1
   		start_all_daemons 2>&1

        if [ -f $BOTFORCERESTART ];
        then
            JAMESCHECK=$(ps -ef | grep "python ./james.py" | grep -v grep | awk '{ print $2 }')
            if [ "a" != "a$JAMESCHECK" ];
            then
                $BASEDIR/new_event.sh alert "Forced restarting Sir James" ""
                kill $JAMESCHECK
            fi
            rm $BOTFORCERESTART
        fi
    ;;


    ##Cam events
    cam_dc)
        $BASEDIR/new_event.sh alert "Cam disconnected" ""
    ;;

    cam_mov)
        if [ $($BASEDIR/new_event.sh is_at_home) -eq 1 ];
        then
            rm $2
        else
			echo "Movement detected"
            $BASEDIR/new_event.sh alert "Movement detected" "" &
        fi
        transfer_file $2 &
    ;;

    cam_img)
        if [ $($BASEDIR/new_event.sh is_at_home) -eq 1 ];
        then
            rm $2
        else
			echo "Movement image recorded"
			cp ${2} $DROPBOXDIR
			$BASEDIR/new_event.sh alert "New proximity file available." "$DROPBOXURL$(basename ${2})"
        fi
        transfer_file $2 &
    ;;


    ## Proximity events
    prx_at_home)
        /etc/init.d/motion stop >/dev/null 2>&1
        /usr/sbin/etherwake -i "$NETINTERFACE" "$COMPUTERMAC"
    ;;

    prx_went_away)
        /etc/init.d/motion start >/dev/null 2>&1
        #$(which mpc) stop
    ;;


    ## Proximity events
    scan_host)
        function scanHostRun {
			#get a actual oui file from http://standards.ieee.org/develop/regauth/oui/oui.txt
		    oui=$(sed -ne '{
		        # strip all punctuation
		        s/[\.:\-]//g
		
		        # convert to uppercase
		        s/[a-f]/\u&/g
		
		        # rewrite to canonical format
		        s/^\([0-9A-F]\{2\}\)\([0-9A-F]\{2\}\)\([0-9A-F]\{2\}\).*/\1-\2-\3/p
		    } ' <<< $2)

            DATE=$(date)
			HOSTNAME=$(host $1 | awk {'print $5'} | awk -F. '{ print $1 }')
            MACV=$(sed -n "/^${oui}/,/^$/p" ${MACVENDORFILE})
            NMAP=$(/usr/bin/nmap -O $1)
			NBTSCAN=$(/usr/bin/nbtscan $1)
            echo -e "========= $HOSTNAME =========\nDate: $DATE\n\n$MACV\n\n$NBTSCAN\n\n$NMAP" >> $NEWFILE
            $BASEDIR/new_event.sh alert "Unknown host $HOSTNAME scanned." "" # "\n$DATE\n$HOSTNAME\n$MACV\n$NMAPR"
        }
        scanHostRun $2 $3 &
    ;;

    arp_scan)
        $(which arp-scan) -I $NETINTERFACE -q --localnet | sort -t . -k 1,1n -k 2,2n -k 3,3n -k 4,4n
    ;;

	is_at_home)
		HOST=$(get_node_name "proximity")
		if [ $HOST == "localhost" ];
		then
		#	echo "processing proximity query on $(host $(hostname) | awk '{ print $1 }')" >&2
	        is_at_home
		else
			ssh root@$HOST /opt/james/new_event.sh is_at_home
		fi
	;;

    alert)
		HOST=$(get_node_name "alert")
		if [ $HOST == "localhost" ];
		then
		#	echo "processing alert event on $(host $(hostname) | awk '{ print $1 }')" >&2
	        alert "$2" "$3"
		else
			ssh root@$HOST /opt/james/new_event.sh alert "\"$2\"" "\"$3\""
		fi
    ;;


	## XBMC events
	xbmc_update)
		$BASEDIR/scripts/xbmc.php update > /dev/null &
		#alert "XBMC video database is updating."
	;;


	## RabbitMQ events
	rabbitmq_status)
		$BASEDIR/scripts/irabbitmqstatus.sh &
	;;


	## Raspbery Pi events
	rasp)
		HOST=$(get_node_name "rasp")
		if [ $HOST == "localhost" ];
		then
		#	echo "processing rasp event on $(host $(hostname) | awk '{ print $1 }')" >&2
			$BASEDIR/scripts/rasp.php "$2" "$3" "$4" "$5"
		else
			ssh root@$HOST /opt/james/new_event.sh rasp "$2" "$3" "$4" "$5"
		fi
	;;


    ## Default event
    *)
        echo "unknown event: <$1>, please specify one"
    ;;
esac
