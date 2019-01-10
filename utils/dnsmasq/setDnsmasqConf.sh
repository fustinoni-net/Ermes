#!/bin/bash

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
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

AP_SSID=${$AP_SSID}
TMPL_FILE=${INSTALL_DIR}${DNSMQSQ_UTILS_DIR}conf/dnsmasq.conf.tmpl

if test ! -f $TMPL_FILE ; then 
	exit 1
fi

AP_INTERFACE=$1

JAIL=""
if [ "$2" = "n" ]; then
	JAIL="#"
fi

ADS_BLOCK="#"
if [ "$3" = "y" ]; then
        ADS_BLOCK=""
fi

#echo "$AP_INTERFACE jail  $JAIL  ads $ADS_BLOCK"

export AP_CHANNEL AP_INTERFACE JAIL ADS_BLOCK AP_SSID

TEMP_FILE=${INSTALL_DIR}${DNSMQSQ_UTILS_DIR}conf/dnsmasq.conf
DESTINATION_FILE=/etc/dnsmasq.conf
DESTINATION_FILE_BACKUP=/etc/dnsmasq.conf.backup

cat $TMPL_FILE | envsubst > $TEMP_FILE


sudo cp $DESTINATION_FILE $DESTINATION_FILE_BACKUP
sudo cp $TEMP_FILE $DESTINATION_FILE

sudo service dnsmasq restart

#sudo service dnsmasq stop
#sudo service dnsmasq start
#sudo service hostapd stop
#sudo service hostapd start

