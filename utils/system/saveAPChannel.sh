#!/bin/bash

base_dir=${INSTALL_DIR}
AP_WLAN=${ACCESS_POINT_DEV}
AP_CHA_FILE=${base_dir}apchannel.info

if [ ! -z "$1" ]; then
	AP_WLAN=$1
fi

AP_CHANNEL=`iw dev $AP_WLAN info | grep channel | sed 's/.*channel \([0-9]*\).*/\1/g'`

#echo "CHANNEL $AP_CHANNEL"
if ([[ "$AP_CHANNEL" =~ ^[0-9]+$ ]] && [ "$AP_CHANNEL" -ge 1 -a "$AP_CHANNEL" -le 13 ]); then
           #echo "CHANNEL $AP_CHANNEL"
           echo $AP_CHANNEL > ${AP_CHA_FILE}
fi
