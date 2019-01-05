#!/bin/bash

if [ -z "$1" ] || [ -z "$2" ]; then
        echo "Usage: $0 AP_INTERFACE WLAN_INTERFACE"
        exit 1
fi



TMPL_FILE=${INSTALL_DIR}${DHCPCD_UTILS_DIR}conf/dhcpcd.conf.tmpl

if test ! -f $TMPL_FILE ; then 
	exit 1
fi

AP_INTERFACE=$1
WLAN_INTERFACE=$2

export AP_INTERFACE WLAN_INTERFACE

TEMP_FILE=${INSTALL_DIR}${DHCPCD_UTILS_DIR}conf/dhcpcd.conf
DESTINATION_FILE=/etc/dhcpcd.conf
DESTINATION_FILE_BACKUP=/etc/dhcpcd.conf.backup

cat $TMPL_FILE | envsubst > $TEMP_FILE


sudo cp $DESTINATION_FILE $DESTINATION_FILE_BACKUP
sudo cp $TEMP_FILE $DESTINATION_FILE

