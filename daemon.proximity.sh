#!/bin/bash
source /opt/james/settings/settings.sh
source $BASEDIR/include/func.*.sh

echo -e "\nJames Proximity monitor is now starting"
alert "James proximity monitor active" &

PONLINE=0;
STATE=2
while /bin/true; do
    if [[ "$(check_pconnection)" -eq 1 ]];
    then
	PONLINE=1
	echo -e "DEBUG: $(date) $PINGDEVICEMAC online" >> $PDBGLOG

	if [ $STATE -ne "1" ];
	then
            cd $BOTDIR
            ONLINE=$($WHOISONLINE)
            cd $INPWD
            alert "Welcome home master. Perimeter defence deactivated." &
            echo -e "$(date) master came home"
            STATE=1
	fi

        echo 1 > $PSTATEFILE
	$BASEDIR/new_event.sh prx_at_home "Sleeping long ($PLONG secs)"
        echo -e "$(date)\tsleeping for $PLONG seconds"

	sleep $PLONG

	while [[ $PONLINE -eq 1 ]]; do
	    if [[ "$(check_pconnection)" -eq 1 ]]; then
		echo -e "DEBUG: $(date) $PINGDEVICEMAC still online" >> $PDBGLOG
                echo -e "$(date)\tmaster still home, sleeping for $PLONG seconds"
		sleep $PLONG
	    else
		PONLINE=0
		echo -e "DEBUG: $(date) $PINGDEVICEMAC not longer online." >> $PDBGLOG
                echo -e "$(date)\tdevice away, sleeping for $PSHORT seconds"
		sleep $PSHORT
	    fi
	done
    else
	PONLINE=0
	echo -e "DEBUG: $(date) $PINGDEVICEMAC offline, short wait loop" >> $PDBGLOG

	if [ $STATE -ne "0" ];
	then
            cd $BOTDIR
            ONLINE=$($WHOISONLINE)
            cd $INPWD
            alert "You left. Perimeter defence enabled" &
            echo -e "$(date)\tmaster went away! i am now a watchdog"

            STATE=0
	fi

        echo 0 > $PSTATEFILE
	$BASEDIR/new_event.sh prx_went_away "Sleeping short ($PSHORT)"
        echo -e "$(date)\tsleeping for $PSHORT seconds"

	sleep $PSHORT
    fi
done