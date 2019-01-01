#!/bin/bash


if [ -z "$1" ]; then
        echo "Usage: $0 interface"
        exit 1
fi

wlan=$1
tcp_port=1234


rm -f /tmp/wp_in_$wlan
rm -f /tmp/wp_out_$wlan

mkfifo /tmp/wp_in_$wlan
mkfifo /tmp/wp_out_$wlan

cat /tmp/wp_in_$wlan | nc -uU /var/run/wpa_supplicant/$wlan > /tmp/wp_out_$wlan &
cat /tmp/wp_out_$wlan | nc -lk 127.0.0.1 $tcp_port > /tmp/wp_in_$wlan &
