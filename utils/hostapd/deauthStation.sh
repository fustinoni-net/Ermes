#!/bin/bash


mapfile -t my_array < <(iwconfig 2> /dev/null |grep wlan | sed 's/\(wlan[0-9]*\).*/\1/g')
if [[ " ${my_array[@]} " =~ " wlan1 " ]]; then
    # whatever you want to do when arr contains value
    #echo "found wlan1"
        exit 0
fi

base_dir=${INSTALL_DIR}
AP_WLAN=${ACCESS_POINT_DEV}
AP_OLD_CHA_FILE=${base_dir}apchannel.info

if [ ! -z "$1" ]; then
	AP_WLAN=$1
fi

if [ ! -f $AP_OLD_CHA_FILE ]; then
        exit 1
fi

OLD_AP_CHANNEL=$(<$AP_OLD_CHA_FILE)



AP_CHANNEL=`iw dev $AP_WLAN info  2>/dev/null | grep channel | sed 's/.*channel \([0-9]*\).*/\1/g'`

if [ -z "$AP_CHANNEL" ]; then
	exit 2
fi

#echo "CHANNEL $AP_CHANNEL"
#echo "OLD CHANNEL $OLD_AP_CHANNEL"

if (! [[ "$AP_CHANNEL" =~ ^[0-9]+$ ]] && [ "$AP_CHANNEL" -ge 1 -a "$AP_CHANNEL" -le 13 ]); then
           #echo "CHANNEL $AP_CHANNEL"
           exit 3
fi

if (! [[ "$OLD_AP_CHANNEL" =~ ^[0-9]+$ ]] && [ "$OLD_AP_CHANNEL" -ge 1 -a "$OLD_AP_CHANNEL" -le 13 ]); then
           #echo "CHANNEL $OLD_AP_CHANNEL"
           exit 4
fi

if [ $AP_CHANNEL -ne $OLD_AP_CHANNEL ]; then
	${base_dir}execDeauthStation.sh
	${base_dir}saveAPChannel.sh
fi
