#!/bin/bash

ap=${ACCESS_POINT_DEV}
wlan=$1

iptables -t nat -A POSTROUTING -o $wlan -j MASQUERADE
#iptables -A FORWARD -i $wlan -o $ap -m state --state RELATED,ESTABLISHED -j ACCEPT
#iptables -A FORWARD -i $ap -o $wlan -j ACCEPT
