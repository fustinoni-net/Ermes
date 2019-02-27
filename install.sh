#!/bin/bash

# personalized

# Set the access point SSID
AP_SSID=ermes

# Set the access point passphrase
AP_PASSPHRASE=12345678

# Set the access point channel
AP_CHANNEL=11
# Set the install directory path
INSTALL_DIR=/home/pi/wifiExtender/

# end personalized

# At your own risk

# To automatically modify the file /etc/rc.local
# set RC_LOCAL_CHANGE=yes
RC_LOCAL_CHANGE=yes

#end at your own risk

# Base dev interfaces
BASE_WIFI_DEV=wlan0
ACCESS_POINT_DEV=ap0

# project subdir do not modify
SYSTEM_UTILS_DIR=utils/system/
DNSMQSQ_UTILS_DIR=utils/dnsmasq/
DHCPCD_UTILS_DIR=utils/dhcpcd/
HOSTAPD_UTILS_DIR=utils/hostapd/
WPA_SUPPLICANT_UTILS_DIR=utils/wpa_supplicant/

# export for files customization
export INSTALL_DIR SYSTEM_UTILS_DIR DNSMQSQ_UTILS_DIR HOSTAPD_UTILS_DIR WPA_SUPPLICANT_UTILS_DIR DHCPCD_UTILS_DIR
export ACCESS_POINT_DEV BASE_WIFI_DEV AP_SSID AP_PASSPHRASE


function setupFile {
	cat $1 | envsubst '$INSTALL_DIR $SYSTEM_UTILS_DIR $DNSMQSQ_UTILS_DIR $HOSTAPD_UTILS_DIR $DHCPCD_UTILS_DIR  \
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
setupFile setJail.sh
setupFile setDnsMasqOptions.sh

#setup dnsmasq files 
createDir ${INSTALL_DIR}${DNSMQSQ_UTILS_DIR}

setupFile ${DNSMQSQ_UTILS_DIR}setDnsmasqConf.sh

createDir ${INSTALL_DIR}${DNSMQSQ_UTILS_DIR}/conf
cp ${pwd}${DNSMQSQ_UTILS_DIR}conf/dnsmasq.conf.tmpl ${INSTALL_DIR}${DNSMQSQ_UTILS_DIR}conf/

#setup dhcpcd files
createDir ${INSTALL_DIR}${DHCPCD_UTILS_DIR}

setupFile ${DHCPCD_UTILS_DIR}setDhcpcdConf.sh

createDir ${INSTALL_DIR}${DHCPCD_UTILS_DIR}/conf
cp ${pwd}${DHCPCD_UTILS_DIR}conf/dhcpcd.conf.tmpl ${INSTALL_DIR}${DHCPCD_UTILS_DIR}conf/


#setup hostapd files
createDir ${INSTALL_DIR}${HOSTAPD_UTILS_DIR}

setupFile ${HOSTAPD_UTILS_DIR}deauthStation.sh
setupFile ${HOSTAPD_UTILS_DIR}execDeauthStation.sh
setupFile ${HOSTAPD_UTILS_DIR}setHostapdConf.sh

createDir ${INSTALL_DIR}${HOSTAPD_UTILS_DIR}/conf
cp ${pwd}${HOSTAPD_UTILS_DIR}conf/hostapd.conf.tmpl ${INSTALL_DIR}${HOSTAPD_UTILS_DIR}conf/



#setup system files
#cp ${SYSTEM_UTILS_DIR}90-wireless.rules /etc/udev/rules.d/

createDir ${INSTALL_DIR}${SYSTEM_UTILS_DIR}

setupFile ${SYSTEM_UTILS_DIR}removeBaseRoute.sh
setupFile ${SYSTEM_UTILS_DIR}saveAPChannel.sh
setupFile ${SYSTEM_UTILS_DIR}setBaseRoute.sh
setupFile ${SYSTEM_UTILS_DIR}removeVPNRoute.sh
setupFile ${SYSTEM_UTILS_DIR}setVPNRoute.sh
setupFile ${SYSTEM_UTILS_DIR}isBaseRouteEnable.sh


#setup wpa_supplicant files
createDir ${INSTALL_DIR}${WPA_SUPPLICANT_UTILS_DIR}
setupFile ${WPA_SUPPLICANT_UTILS_DIR}wpa_events.sh
#setupFile ${base_dir}${WPA_SUPPLICANT_UTILS_DIR}createWpa_supplicantTCPInterface.sh
#cp  ${pwd}${WPA_SUPPLICANT_UTILS_DIR}wpaTcpGateway.py ${INSTALL_DIR}${WPA_SUPPLICANT_UTILS_DIR}
#Considerare se creare un wpa_supplicant.conf con parametri per wpa_cli
#nel caso deve contenere almeno una rete configurata

#change to /etc/rc.local
if [ $(cat /etc/rc.local |grep startWiFiExtender.sh |wc -l) !=  1 ]; then
	if [ "$RC_LOCAL_CHANGE" = "yes" ]; then
		echo "File /etc/rc.local modified"
		echo "a backup copy off the file is made /etc/rc.local.wifiExtender"
	        cp /etc/rc.local /etc/rc.local.wifiExtender
        	sed  "s|exit 0$|${INSTALL_DIR}startWiFiExtender.sh \&\nexit 0|" /etc/rc.local.wifiExtender > /etc/rc.local
	else
		echo "Remeber to modify the file: /etc/rc.local"
		echo "add '${INSTALL_DIR}startWiFiExtender.sh &' before the line: 'exit 0'"
        fi
else
	echo "File /etc/rc.local already modified"
fi



#if [ $(cat /etc/rc.local |grep startWiFiExtender.sh |wc -l) !=  1 ]; then
#	cp /etc/rc.local /etc/rc.local.wifiExtender
#
#fi


apt-get update
apt-get upgrade
apt-get -y install hostapd dnsmasq haveged openvpn

#systemctl stop dnsmasq
#systemctl stop hostapd
#systemctl stop openvpn.service

systemctl disable wpa_supplicant.service
systemctl disable dnsmasq
systemctl disable hostapd
systemctl disable openvpn.service
#systemctl disable dhcpcd

#setup dnsmasq and hostapd config file
echo "setup dnsmasq, dhcpcd and hostapd config file..."
${INSTALL_DIR}${HOSTAPD_UTILS_DIR}setHostapdConf.sh $ACCESS_POINT_DEV ${AP_CHANNEL}
${INSTALL_DIR}${DNSMQSQ_UTILS_DIR}setDnsmasqConf.sh $ACCESS_POINT_DEV y n
${INSTALL_DIR}${DHCPCD_UTILS_DIR}setDhcpcdConf.sh $ACCESS_POINT_DEV ${BASE_WIFI_DEV}
