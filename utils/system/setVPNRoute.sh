#!/bin/bash

ap=${ACCESS_POINT_DEV}
wlan=$1

sudo iptables -t nat -A POSTROUTING -o tun0 -j MASQUERADE

