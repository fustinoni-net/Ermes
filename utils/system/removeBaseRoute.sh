#!/bin/bash

ap=${ACCESS_POINT_DEV}
wlan=$1

iptables -t nat -D POSTROUTING -o $wlan -j MASQUERADE

#iptables -D FORWARD -i $wlan -o $ap -m state --state RELATED,ESTABLISHED -j ACCEPT
#iptables -D FORWARD -i $ap -o $wlan -j ACCEPT
