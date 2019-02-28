#!/bin/bash

base_dir=${INSTALL_DIR}
wlan=${BASE_WIFI_DEV}
ap=${ACCESS_POINT_DEV}

FK_CONN_CHECK_FILE=${INSTALL_DIR}kk_conn_check

mapfile -t my_array < <(iwconfig 2> /dev/null |grep wlan | sed 's/\(wlan[0-9]*\).*/\1/g')
if [[ " ${my_array[@]} " =~ " wlan1 " ]]; then
    #echo "found wlan1"
	wlan=wlan1
fi

# maybe just when  there is only one wlan present?
iwconfig wlan0  power off

sudo iw dev ap0 set power_save off

/sbin/iw dev wlan0 interface add $ap type __ap

${base_dir}${DHCPCD_UTILS_DIR}setDhcpcdConf.sh $ap $wlan
systemctl start dhcpcd
systemctl daemon-reload

/usr/sbin/hostapd -B /etc/hostapd/hostapd.conf
service dnsmasq start

/sbin/wpa_supplicant -B -c/etc/wpa_supplicant/wpa_supplicant.conf -i$wlan -Dnl80211,wext
/sbin/wpa_cli -i$wlan -B -a ${base_dir}${WPA_SUPPLICANT_UTILS_DIR}wpa_events.sh
#${base_dir}${WPA_SUPPLICANT_UTILS_DIR}createWpa_supplicantTCPInterface.sh $wlan

#iptables -t nat -A POSTROUTING -o $wlan -j MASQUERADE
#iptables -A FORWARD -i $wlan -o ap0 -m state --state RELATED,ESTABLISHED -j ACCEPT
#iptables -A FORWARD -i ap0 -o $wlan -j ACCEPT

#check on the following line. Should not be needed
sysctl net.ipv4.ip_forward=1

#${base_dir}${SYSTEM_UTILS_DIR}setBaseRoute.sh $wlan

${base_dir}${SYSTEM_UTILS_DIR}saveAPChannel.sh

if  [ ! -f $FK_CONN_CHECK_FILE ]
then
    touch $FK_CONN_CHECK_FILE
fi

${base_dir}setDnsMasqOptions.sh

#sudo systemctl start lighttpd.service
