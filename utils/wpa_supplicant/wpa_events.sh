#!/bin/bash

base_dir=${INSTALL_DIR}

if [ -z "$1" ] || [ -z "$2" ]; then
        echo "Usage: $0 IFACE ACTION"
        exit 1
fi


echo  $(date)  $* >> ${base_dir}wpa_log.txt

# network interface
WPA_IFACE="$1"
# [CONNECTED|DISCONNECTED|stop|reload|check]
WPA_ACTION="$2"


case "$WPA_ACTION" in
        "CONNECTED")
		${base_dir}${HOSTAPD_UTILS_DIR}deauthStation.sh
                ;;

        "DISCONNECTED")

                ;;

        "stop"|"down")

                ;;

        "restart"|"reload")

                ;;

        "check")

                ;;

        *)
                echo "Unknown action: \"$WPA_ACTION\""
                exit 1
                ;;
esac

exit 0
