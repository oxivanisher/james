#!/bin/bash

. /opt/james/settings/settings.sh
. /opt/james/include/func.proximity.sh
. /opt/james/include/func.scanhost.sh

if [ -f $PSTATEFILE ];
then
    PSTATE=$(cat $PSTATEFILE)
else
    touch $PSTATEFILE
fi


case "$1" in
	#cam events
	cam_dc)
		$ALERT "Cam disconnected"
		echo -e "event(cam_dc) $2 $(date +%H:%M:%S)" >> $LOG
	;;

	cam_mov)
		if [ $PSTATE -eq 1 ];
		then
			rm $2
		else
			$ALERT "Movement detected" &
       			echo -e "event(cam_mov) $2 $(date +%H:%M:%S)" >> $LOG
       	fi
		transfer_file $2 &
	;;

	cam_img)
		if [ $PSTATE -eq 1 ];
		then
			rm $2
		else
#			uuencode ${2} $(basename ${2}) | mail -s "Cam image event detected $(date +%H:%M:%S)" $EMAIL &
			echo -e "event(cam_img) $2 $(date +%H:%M:%S)" >> $LOG
		fi
		transfer_file $2 &
	;;


	#proximity events
	prx_at_home)
		echo 1 > $PSTATEFILE
		/etc/init.d/motion stop >/dev/null 2>&1
		$ETHERWAKE $COMPUTER
		echo -e "event(prx_at_home) $2 $(date +%H:%M:%S)" >> $LOG
	;;

	prx_went_away)
		echo 0 > $PSTATEFILE
		/etc/init.d/motion start >/dev/null 2>&1
		echo -e "event(prx_went_away) $2 $(date +%H:%M:%S)" >> $LOG
	;;

	sys_startup)
		echo -e "event(sys_startup) $2 $(date +%H:%M:%S)" >> $LOG
		echo -e "\n\n\nJames system bot for beagleboard. Powered by oXi:"
		echo -e "\tCreating tmp directory"
		mkdir -p /tmp/motion/
		chmod 777 /tmp/motion/
       
		echo -e -n "\tStarting daemons: "
                if [ "$(screen -ls | grep proximity-daemon)a" == "a" ];
                then
                    echo -e -n "proximity-daemon ";
                    screen -dmS proximity-daemon $BASEDIR/daemon.proximity.sh
                fi

                if [ "$(screen -ls | grep xmpp-daemon)a" == "a" ];
                then
                    echo -e -n "xmpp-daemon ";
                    screen -dmS xmpp-daemon $BASEDIR/daemon.xmpp.sh &
                fi

		echo -e "\n=> Everything is running now\n\n\n"
		exit 0
	;;
	

	sys_reboot)
		$ALERT "$(hostname) is rebooting"
		echo -e "event(sys_reboot) by $(whoami) $(date +%H:%M:%S) $2" >> $LOG
		reboot &
	;;

	sys_poweroff)
		$ALERT "$(hostname) is powering down"
		echo -e "event(sys_poweroff) by $(whoami) $(date +%H:%M:%S) $2" >> $LOG
		poweroff &
	;;


        scan_host)
                function run {
                    DATE=$(date)
                    MACV=get_mac_vendor $1
                    NMAPR=nmap_scan $2
                    echo -e "$DATE\n$MACV\n$NMAPR" >> $NEWFILE
                    $ALERT "Unknown host detected" "\n$DATE\n$MACV\n$NMAPR"
                }
                run $1 $2 &
        ;;

       arp_scan)
            $ARPSCAN -I $NETINTERFACE -q --localnet | sort -t . -k 1,1n -k 2,2n -k 3,3n -k 4,4n
        ;;


        alert)
            $ALERT $@
        ;;

        periodic)
            $BASEDIR/scripts/whoisonline.sh >/dev/null 2>&1
            if [ -f $BOTFORCERESTART ];
            then
                JAMESCHECK=$(ps -ef | grep "python ./james.py" | grep -v grep | awk '{ print $2 }')
                if [ "a" != "a$JAMESCHECK" ];
                then
                     $ALERT "Restarting Sir James"
                     kill $JAMESCHECK
                fi
                rm $BOTFORCERESTART
            fi
        ;;


	#default event
	*)
		echo "error, please specify a facility"
	;;
esac
