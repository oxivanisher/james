#!/bin/bash
source /opt/james/settings/settings.sh
source $BASEDIR/include/func.*.sh

if [ -f $PSTATEFILE ];
then
    PSTATE=$(cat $PSTATEFILE)
else
    touch $PSTATEFILE
fi

case "$1" in
    #cam events
    cam_dc)
        alert "Cam disconnected"
        echo -e "event(cam_dc) $2 $(date +%H:%M:%S)" >> $MAINLOG
    ;;

    cam_mov)
        if [ $PSTATE -eq 1 ];
        then
            rm $2
        else
            alert "Movement detected" &
            echo -e "event(cam_mov) $2 $(date +%H:%M:%S)" >> $MAINLOG
        fi
        transfer_file $2 &
    ;;

    cam_img)
        if [ $PSTATE -eq 1 ];
        then
            rm $2
        else
#           uuencode ${2} $(basename ${2}) | mail -s "Cam image event detected $(date +%H:%M:%S)" $EMAIL &
            echo -e "event(cam_img) $2 $(date +%H:%M:%S)" >> $MAINLOG
        fi
        transfer_file $2 &
    ;;


    #proximity events
    prx_at_home)
        echo 1 > $PSTATEFILE
        /etc/init.d/motion stop >/dev/null 2>&1
        /usr/bin/env etherwake -i $NETINTERFACE $COMPUTERMAC
        echo -e "event(prx_at_home) $2 $(date +%H:%M:%S)" >> $MAINLOG
    ;;

    prx_went_away)
        echo 0 > $PSTATEFILE
        /etc/init.d/motion start >/dev/null 2>&1
        echo -e "event(prx_went_away) $2 $(date +%H:%M:%S)" >> $MAINLOG
    ;;

    sys_startup|start)
        echo -e "event(sys_startup) $2 $(date +%H:%M:%S)" >> $MAINLOG
        echo -e "James: Your Buttler startup (syncing time, please wait)"
        /usr/bin/env ntpdate-debian >/dev/null 2>&1

        echo -e -n "\tChecking for needed files: "
        check_files || exit 1
        echo -e "> done"

        if [[ ! -d "$MOTIONDIR" ]];
        then
            echo -e "\tCreating tmp directory"
            mkdir -p $MOTIONDIR
        fi
        chmod 777 $MOTIONDIR

        start_daemons

        echo -e "\t=> Everything is running now\n"
        exit 0
    ;;


    sys_reboot)
        alert "$(hostname) is rebooting"
        echo -e "event(sys_reboot) by $(whoami) $(date +%H:%M:%S) $2" >> $MAINLOG
        reboot &
    ;;

    sys_poweroff)
        alert "$(hostname) is powering down"
        echo -e "event(sys_poweroff) by $(whoami) $(date +%H:%M:%S) $2" >> $MAINLOG
        poweroff &
    ;;

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
        /usr/bin/env arp-scan -I $NETINTERFACE -q --localnet | sort -t . -k 1,1n -k 2,2n -k 3,3n -k 4,4n
    ;;


    alert)
        alert $@
    ;;

    periodic)
        $WHOISONLINE >/dev/null 2>&1

        start_daemons >/dev/null 2>&1

        if [ -f $BOTFORCERESTART ];
        then
            JAMESCHECK=$(ps -ef | grep "python ./james.py" | grep -v grep | awk '{ print $2 }')
            if [ "a" != "a$JAMESCHECK" ];
            then
                alert "Restarting Sir James forced"
                kill $JAMESCHECK
            fi
            rm $BOTFORCERESTART
        fi
    ;;

    #default event
    *)
        echo "error, please specify a command"
    ;;
esac
