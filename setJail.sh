#!/bin/bash

if [ -z "$1" ]; then
        echo "Usage: $0 JAIL [y|n]"
        exit 1
fi


if !([[ "$1" =~ ^[yn]+$ ]]); then
    echo "INVALID JAIL VALUE"
    echo "Usage: $0 JAIL [y|n]"
    exit 1
fi

FORWARD=1
JAIL=n
if [ "$1" = "y" ]; then
	FORWARD=0
	JAIL=y
fi

sysctl net.ipv4.ip_forward=$FORWARD
${INSTALL_DIR}${DNSMQSQ_UTILS_DIR}setDnsmasqConf.sh ${ACCESS_POINT_DEV} $JAIL n
