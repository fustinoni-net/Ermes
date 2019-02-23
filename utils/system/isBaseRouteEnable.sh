#!/bin/bash

active='false'

if [ -z "$1" ]; then
        echo "Usage: $0  wlan"
        exit 1
fi

mapfile -t my_array < <(sudo iptables -t nat -v -L POSTROUTING -n --line-number 2> /dev/null |grep wlan | sed 's/.*MASQUERADE.*\(wlan[0-9]*\).*/\1/g')
if [[ "${my_array[@]}" =~ $1 ]]; then
    #echo "active"
    active='true'

fi

echo $active
