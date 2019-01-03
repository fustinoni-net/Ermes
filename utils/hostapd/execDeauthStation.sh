#!/bin/bash

# consider using disassociate instead off deauthenticate

ap=${ACCESS_POINT_DEV}
 
mapfile -t my_array < <(iw dev $ap station dump |grep Station | sed 's/Station \(.*\) (.*/\1/g')

for i in ${my_array[@]}; do
       #hostapd_cli -i $ap  deauthenticate $i
	hostapd_cli -i $ap  disassociate $i
done

