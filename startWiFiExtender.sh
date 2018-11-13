#!/bin/bash

base_dir=${INSTALL_DIR}
wlan=${BASE_WIFI_DEV}
ap=${ACCESS_POINT_DEV}


mapfile -t my_array < <(iwconfig 2> /dev/null |grep wlan | sed 's/\(wlan[0-9]*\).*/\1/g')
if [[ " ${my_array[@]} " =~ " wlan1 " ]]; then
    # whatever you want to do when arr contains value
    #echo "found wlan1"
	wlan=wlan1
fi

iwconfig $wlan power off
#/sbin/iw dev wlan0 interface add $ap type __ap

/usr/sbin/hostapd -B /etc/hostapd/hostapd.conf
service dnsmasq start

/sbin/wpa_supplicant -B -c/etc/wpa_supplicant/wpa_supplicant.conf -i$wlan -Dnl80211,wext
/sbin/wpa_cli -i$wlan -B -a ${base_dir}wpa_events.sh

#iptables -t nat -A POSTROUTING -o $wlan -j MASQUERADE
#iptables -A FORWARD -i $wlan -o ap0 -m state --state RELATED,ESTABLISHED -j ACCEPT
#iptables -A FORWARD -i ap0 -o $wlan -j ACCEPT

${base_dir}setBaseRoute.sh $wlan

${base_dir}saveAPChannel.sh
