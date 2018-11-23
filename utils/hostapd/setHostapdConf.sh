#!/bin/bash

if [ -z "$1" ] || [ -z "$2" ]; then
        echo "Usage: $0 AP_INTERFACE REBOOT AP_CHANNEL"
        exit 1
fi


if !([[ "$2" =~ ^[0-9]+$ ]] && [ "$2" -ge 1 -a "$2" -le 13 ]); then
    echo "INVALID CHANNEL"
    exit 1
fi


TMPL_FILE=${INSTALL_DIR}${HOSTAPD_UTILS_DIR}conf/hostapd.conf.tmpl

if test ! -f $TMPL_FILE ; then 
	exit 1
fi

AP_SSID=${AP_SSID}
AP_PASSPHRASE=${AP_PASSPHRASE}

AP_CHANNEL=$2
AP_INTERFACE=$1

export AP_CHANNEL AP_INTERFACE AP_SSID AP_PASSPHRASE

TEMP_FILE=${INSTALL_DIR}${HOSTAPD_UTILS_DIR}conf/hostapd.conf
DESTINATION_FILE=/etc/hostapd/hostapd.conf
DESTINATION_FILE_BACKUP=/etc/hostapd/hostapd.conf.backup

cat $TMPL_FILE | envsubst > $TEMP_FILE


sudo cp $DESTINATION_FILE $DESTINATION_FILE_BACKUP
sudo cp $TEMP_FILE $DESTINATION_FILE

#sudo reboot
