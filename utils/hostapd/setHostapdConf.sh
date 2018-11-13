#!/bin/bash

if [ -z "$1" ] || [ -z "$2" ]; then
        echo "Usage: $0 AP_CHANNEL AP_INTERFACE REBOOT"
        exit 1
fi


if !([[ "$1" =~ ^[0-9]+$ ]] && [ "$1" -ge 1 -a "$1" -le 13 ]); then
    echo "INVALID CHANNEL"
    exit 1
fi


TMPL_FILE=$(pwd)/conf/hostapd.conf.tmpl

if test ! -f $TMPL_FILE ; then 
	exit 1
fi

AP_SSID=${AP_SSID}
AP_PASSPHRASE=${AP_PASSPHRASE}

AP_CHANNEL=$1
AP_INTERFACE=$2

export AP_CHANNEL AP_INTERFACE AP_SSID AP_PASSPHRASE

TEMP_FILE=$(pwd)/conf/hostapd.conf
DESTINATION_FILE=/etc/hostapd/hostapd.conf
DESTINATION_FILE_BACKUP=/etc/hostapd/hostapd.conf.backup

cat $TMPL_FILE | envsubst > $TEMP_FILE


sudo cp $DESTINATION_FILE $DESTINATION_FILE_BACKUP
sudo cp $TEMP_FILE $DESTINATION_FILE

#sudo reboot
