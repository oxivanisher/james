#!/bin/bash
source /opt/james/settings/settings.sh
source $BASEDIR/include/func.*.sh

if [ -f $PSTATEFILE ];
then
    PSTATE=$(cat $PSTATEFILE)
else
    echo 0 > $PSTATEFILE
fi

echo -e "event($1) $2 $(date +%H:%M:%S)" >> $MAINLOG
case "$1" in
    ## System events
    sys_reboot)
        alert "$(hostname) is rebooting"
        reboot &
    ;;

    sys_poweroff)
        alert "$(hostname) is powering down"
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
        start_daemon jabber
        start_daemon alert
        start_daemon proximity
        echo -e "> done"

        echo -e "\t=> Everything is running now\n"
        exit 0
    ;;

    periodic)
        $WHOISONLINE >/dev/null 2>&1

        start_daemon jabber >/dev/null 2>&1
        start_daemon alert >/dev/null 2>&1
        start_daemon proximity >/dev/null 2>&1

        if [ -f $BOTFORCERESTART ];
        then
            JAMESCHECK=$(ps -ef | grep "python ./james.py" | grep -v grep | awk '{ print $2 }')
            if [ "a" != "a$JAMESCHECK" ];
            then
                alert "Forced restarting Sir James"
                kill $JAMESCHECK
            fi
            rm $BOTFORCERESTART
        fi
    ;;


    ##Cam events
    cam_dc)
        alert "Cam disconnected"
    ;;

    cam_mov)
        if [ $PSTATE -eq 1 ];
        then
            rm $2
        else
            alert "Movement detected" &
        fi
        transfer_file $2 &
    ;;

    cam_img)
        if [ $PSTATE -eq 1 ];
        then
            rm $2
        else
#           uuencode ${2} $(basename ${2}) | mail -s "Cam image event detected $(date +%H:%M:%S)" $EMAIL &
            true
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
        function run {
            DATE=$(date)
            MACV=get_mac_vendor $1
            NMAPR=nmap_scan $2
            echo -e "$DATE\n$MACV\n$NMAPR" >> $NEWFILE
            alert "Unknown host detected" "\n$DATE\n$MACV\n$NMAPR"
        }
        run $1 $2 &
    ;;

    arp_scan)
        $(which arp-scan) -I $NETINTERFACE -q --localnet | sort -t . -k 1,1n -k 2,2n -k 3,3n -k 4,4n
    ;;

    alert)
        alert "$2" "$3"
    ;;


	## XBMC events
	xbmc_update)
		$BASEDIR/scripts/xbmc.php update > /dev/null &
		#alert "XBMC video database is updating."
	;;


    ## Default event
    *)
        echo "error, please specify a event"
    ;;
esac
