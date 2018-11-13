#!/bin/bash

# personalized

AP_SSID=ermes
AP_PASSPHRASE=12345678
AP_CHANNEL=1
INSTALL_DIR=/home/pi/wifiExtender/

# end personalize

# Base dev interfaces
BASE_WIFI_DEV=wlan0
ACCESS_POINT_DEV=ap0

# project subdir
SYSTEM_UTILS_DIR=utils/system/
DNSMQSQ_UTILS_DIR=utils/dnsmasq/
HOSTAPD_UTILS_DIR=utils/hostapd/
WPA_SUPPLICANT_UTILS_DIR=utils/wpa_supplicant/

# export for files customization
export INSTALL_DIR SYSTEM_UTILS_DIR DNSMQSQ_UTILS_DIR HOSTAPD_UTILS_DIR WPA_SUPPLICANT_UTILS_DIR
export ACCESS_POINT_DEV BASE_WIFI_DEV AP_SSID AP_PASSPHRASE


function setupFile {
	cat $1 | envsubst '$INSTALL_DIR $SYSTEM_UTILS_DIR $DNSMQSQ_UTILS_DIR $HOSTAPD_UTILS_DIR  \
		$WPA_SUPPLICANT_UTILS_DIR $ACCESS_POINT_DEV $BASE_WIFI_DEV $AP_SSID $AP_PASSPHRASE' > ${INSTALL_DIR}$1
	chmod +x ${INSTALL_DIR}$1
}

function createDir {
	if [ ! -d $1 ]; then
	        mkdir -p $1
	fi
}


#setup base files
createDir ${INSTALL_DIR}

setupFile startWiFiExtender.sh


#setup dnsmasq files 


#setup hostapd files
createDir ${INSTALL_DIR}${HOSTAPD_UTILS_DIR}

setupFile ${HOSTAPD_UTILS_DIR}deauthStation.sh
setupFile ${HOSTAPD_UTILS_DIR}execDeauthStation.sh
setupFile ${HOSTAPD_UTILS_DIR}setHostapdConf.sh

createDir ${INSTALL_DIR}${HOSTAPD_UTILS_DIR}/conf
cp ${pwd}${HOSTAPD_UTILS_DIR}/conf/hostapd.conf.tmpl ${INSTALL_DIR}${HOSTAPD_UTILS_DIR}conf/



#setup system files
#cp ${SYSTEM_UTILS_DIR}90-wireless.rules /etc/udev/rules.d/

createDir ${INSTALL_DIR}${SYSTEM_UTILS_DIR}

setupFile ${SYSTEM_UTILS_DIR}removeBaseRoute.sh
setupFile ${SYSTEM_UTILS_DIR}saveAPChannel.sh
setupFile ${SYSTEM_UTILS_DIR}setBaseRoute.sh

#setup wpa_supplicant files
createDir ${INSTALL_DIR}${WPA_SUPPLICANT_UTILS_DIR}
setupFile ${WPA_SUPPLICANT_UTILS_DIR}wpa_events.sh
#Considerare se creare unwpa_supplicant.conf con parametri per wpa_cli

exit 0


#change rc.local
if [ $(cat rc.local |grep startWiFiExtender.sh\n |wc -l) !=  1 ]; then
        cp /etc/rc.local /etc/rc.local.wifiExtender
        sed  "s|exit 0$|${dir}startWiFiExtender.sh \&\nexit 0|" rc.local.wifiExtender > rc.local
        exit 0
fi

if [ $(cat /etc/rc.local |grep startWiFiExtender.sh |wc -l) !=  1 ]; then
	cp /etc/rc.local /etc/rc.local.wifiExtender
	
fi


apt-get update
apt-get -y install hostapd dnsmasq haveged

#systemctl stop dnsmasq
#systemctl stop dnsmasq

#systemctl disable wpa_supplicant.service
#systemctl disable dnsmasq
#systemctl disable dnsmasq

#setup dnsmasq and hostapd config file
${INSTALL_DIR}setHostapdConf.sh $ACCESS_POINT_DEV $AP_CHANNEL
cp ${INSTALL_DIR}${DNSMQSQ_UTILS_DIR}conf/ /etc/



