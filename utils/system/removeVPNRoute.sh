#!/bin/bash

ap=${ACCESS_POINT_DEV}
wlan=$1

iptables -t nat -D POSTROUTING -o tun0 -j MASQUERADE
