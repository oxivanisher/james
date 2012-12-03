#!/bin/bash
source /opt/james/settings/settings.sh
source $BASEDIR/include/func.*.sh

alert "Alert daemon started"

while true;
do
	if [ -f $ALERTCACHE ];
	then
		if [ $($BASEDIR/new_event.sh is_at_home) -eq 1 ];
		then
			mpc -h mpd -q volume 100
			MPC=$(/root/scripts/mpc_radio_on.sh)
			sleep 2
	        mpc -h mpd -q volume -50
			sleep 1
			$($BASEDIR/scripts/alert.sh "Welcome! It is now $(date +%H:%M).")

			LOGDATA=$(cat $ALERTCACHE) 
			rm $ALERTCACHE

			if [ $(echo "$LOGDATA" | wc -l) == 1 ]; 
			then 
				$($BASEDIR/scripts/alert.sh "Nothing happend while we where appart.")
			else 
				$($BASEDIR/scripts/alert.sh "While we where appart, the following things happend:")
				echo -e "$LOGDATA" | while read LOGLINE; 
				do 
					$($BASEDIR/scripts/alert.sh "${LOGLINE}")
				done

				$($BASEDIR/scripts/alert.sh "End of Log.") 
			fi 
 
	        mpc -h mpd -q volume +50
		fi
	fi

    if [ -f "$ALERTMESSAGES" ];
    then
		echo "$(date) we have messages waiting"
        touch $ALERTMESSAGES.lock
        cp $ALERTMESSAGES $ALERTMESSAGES.tmp
        rm $ALERTMESSAGES
        rm $ALERTMESSAGES.lock
        mpc -h mpd -q volume -50
        while read LINE;
        do
            if [ "a$LINE" != "a" ];
            then
				set -- $LINE
                echo -e "\tmsg: $LINE"
				$($BASEDIR/scripts/alert.sh "${LINE}")
                sleep 0.5
            fi
        done < $ALERTMESSAGES.tmp
        rm $ALERTMESSAGES.tmp
        mpc -h mpd -q volume +50
    else
        sleep 1
    fi
done
