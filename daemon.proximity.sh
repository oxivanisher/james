#!/bin/bash
#set -o verbose sh -v
# Copied from Steven on http://gentoo-wiki.com/Talk:TIP_Bluetooth_Proximity_Monitor

source  /opt/james/settings/settings.sh
source  $BASEDIR/include/func.proximity.sh

echo -e "\nJames is syncing time before we start to serve you"
/usr/bin/env ntpdate-debian >/dev/null 2>&1

echo -e "\nJames Proximity monitor is now starting"
$ALERT "James proximity monitor active" &

INPWD=$(pwd)
PONLINE=0;
STATE=2
while /bin/true; do
    if [[ $(check_pconnection) -eq 1 ]];
    then
	PONLINE=1
	echo -e "DEBUG: $(date) $PINGDEVICEMAC online" >> $PDBGLOG

	if [ $STATE -ne "1" ];
	then
		cd $BOTDIR
		ONLINE=$($WHOISONLINE)
		cd $INPWD
		$ALERT "Welcome home master. Perimeter defence deactivated." &
		STATE=1
	fi
	$BASEDIR/new_event.sh prx_at_home "Sleeping long ($PLONG secs)"

	sleep $PLONG

	while [[ $PONLINE -eq 1 ]]; do
	    if [[ $(check_pconnection) -eq 1 ]]; then
		echo -e "DEBUG: $(date) $PINGDEVICEMAC still online" >> $PDBGLOG
		sleep $PLONG
	    else
		PONLINE=0
		echo -e "DEBUG: $(date) $PINGDEVICEMAC not longer online." >> $PDBGLOG
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
		$ALERT "You left. Perimeter defence enabled" &
		STATE=0
	fi
	$BASEDIR/new_event.sh prx_went_away "Sleeping short ($PSHORT)"

	sleep $PSHORT
    fi
    
done
