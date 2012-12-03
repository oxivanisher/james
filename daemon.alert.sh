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
			LOGDATA=$(cat $ALERTCACHE) 
			rm $ALERTCACHE 
 
			if [ $(echo "$LOGDATA" | wc -l) == 1 ]; 
			then 
				$BASEDIR/new_event.sh alert "Nothing happend while we where appart." & 
			else 
				$BASEDIR/new_event.sh alert "While we where appart, the following things happend:" & 
				echo -e "$LOGDATA" | while read LOGLINE; 
				do 
					$BASEDIR/new_event.sh alert "$LOGLINE" & 
				done

				$BASEDIR/new_event.sh alert "End of Log." & 
			fi 
 
			MPC=$(/root/scripts/mpc_radio_on.sh)
		fi
	fi

    if [ -f "$ALERTMESSAGES" ];
    then
		echo "$(date) we have messages waiting"
        touch $ALERTMESSAGES.lock
        cp $ALERTMESSAGES $ALERTMESSAGES.tmp
        rm $ALERTMESSAGES
        rm $ALERTMESSAGES.lock
        mpc -h mpd -q volume -30
        while read LINE;
        do
            if [ "a$LINE" != "a" ];
            then
				set -- $LINE
                echo -e "\tmsg: $LINE ; $1 ; $2"
				$($BASEDIR/scripts/alert.sh "${LINE}")
                sleep 0.5
            fi
        done < $ALERTMESSAGES.tmp
        rm $ALERTMESSAGES.tmp
        mpc -h mpd -q volume +30
    else
        sleep 1
    fi
done
