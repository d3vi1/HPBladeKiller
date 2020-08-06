#!/bin/bash

export chassis="$1"
export blades=`./listBladesFromOa.expect $chassis show server list | sed -n '/---\ -/,/Totals/p' | grep -v "\-\-\- \-" | grep -v "Totals: " | grep -v "Absent"`
echo "Listing blades:"
echo "$blades"
while read -r line; do
     export id=`echo "$line" | awk '{print $1}'`
     export ip=`echo "$line" | awk '{print $3}'`
     echo "Resetting iLO Password: $id with IP: $ip from OA IP: $chassis"
     ./iLOResetFromOa.expect $chassis $id
done <<<"$blades"
while read -r line; do
     export id=`echo "$line" | awk '{print $1}'`
     export ip=`echo "$line" | awk '{print $3}'`
     echo "Starting disk wipe on IP: $ip"
     ./bootToWipeIsoFromIlo.expect $ip
done <<<"$blades"
echo "Sent command to boot the HPErase ISO to all servers. Waiting one hour before resetting the iLO."
sleep 3600
while read -r line; do
     export id=`echo "$line" | awk '{print $1}'`
     export ip=`echo "$line" | awk '{print $3}'`
     echo "Resetting iLO id: $id with IP: $ip from OA IP: $chassis"
     ./iLOResetFromOa.expect $chassis $id
done <<<"$blades"
