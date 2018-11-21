#!/bin/bash

if [ -z "$1" ] || [ -z "$2" ]; then
        echo "Usage: $0 AP_INTERFACE JAIL [y|n] ADS_BLOCK [y|n]"
        exit 1
fi


if !([[ "$2" =~ ^[yn]+$ ]]); then
    echo "INVALID JAIL VALUE"
    exit 1
fi

if !([[ "$3" =~ ^[yn]+$ ]]); then
    echo "INVALID ADS_BLOCK VALUE"
    exit 1
fi

TMPL_FILE=$(pwd)/conf/dnsmasq.conf.tmpl

if test ! -f $TMPL_FILE ; then 
	exit 1
fi

AP_INTERFACE=$1

echo "jail $2"

JAIL="yy"

if [ "$2" = "n" ]; then
#	echo "no"
	JAIL='nn'
fi

echo "ads $3"

ADS_BLOCK="nn"

if [ "$3" = "y" ]; then
	echo "si"
        ADS_BLOCK='yy'
fi

echo "$AP_INTERFACE jail  $JAIL  ads $ADS_BLOCK"

#export AP_CHANNEL AP_INTERFACE AP_SSID AP_PASSPHRASE

#TEMP_FILE=$(pwd)/conf/hostapd.conf
#DESTINATION_FILE=/etc/hostapd/hostapd.conf
#DESTINATION_FILE_BACKUP=/etc/hostapd/hostapd.conf.backup

#at $TMPL_FILE | envsubst > $TEMP_FILE


#sudo cp $DESTINATION_FILE $DESTINATION_FILE_BACKUP
#sudo cp $TEMP_FILE $DESTINATION_FILE

#sudo reboot
