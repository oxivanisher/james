#!/bin/bash
source /opt/james/settings/settings.sh
source $BASEDIR/include/func.*.sh

alert "Alert daemon started"

while true;
do
    if [ -f "$ALERTMESSAGES" ];
    then
		echo "$(date) we have messages waiting"
        touch $ALERTMESSAGES.lock
        cp $ALERTMESSAGES $ALERTMESSAGES.tmp
        rm $ALERTMESSAGES
        rm $ALERTMESSAGES.lock
        mpc -q volume -30
        while read LINE;
        do
            if [ "a$LINE" != "a" ];
            then
				#MYMSG=$(echo $LINE | awk '{ print $1 " " $2 " " $3}')
				#CLEANMSG=$(echo $MYMSG | sed 's/"//g')
#                echo -e "\tmsg: $CLEANMSG"
#				HEAD=$(echo ${LINE} | awk '{ print $1 }')
#				HEAD=$(eval $LINE | echo $1)
#				BODY=$(echo ${LINE} | awk '{ print $2 }')
				set -- $LINE
                echo -e "\tmsg: $LINE ; $1 ; $2"
#				$BASEDIR/scripts/alert.sh "$CLEANMSG"
				$($BASEDIR/scripts/alert.sh "${LINE}")
                sleep 0.5
            fi
        done < $ALERTMESSAGES.tmp
        rm $ALERTMESSAGES.tmp
        mpc -q volume +30
    else
        sleep 1
    fi
done
