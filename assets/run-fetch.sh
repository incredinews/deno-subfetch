#!/bin/bash


/usr/bin/gobetween -c /etc/gobtw.toml &

date +%s > /tmp/drain_127.0.0.1_10002

while (true); do 
myport=10001

#for m in 1 2 3 4 5;do 
#test -e /tmp/drain_127.0.0.1_$myport && myport=$(($myport+1))
#done

test -e /tmp/drain_127.0.0.1_$myport || myport=10002
[[ "$DEBUG"  == "true" ]] && echo "SWITCH_PORT: $myport"
export PORT=$myport
rm     /tmp/drain_127.0.0.1_$myport ;
timeout 330 /usr/bin/subfetch &
sleep 270 ; 
touch  /tmp/drain_127.0.0.1_$myport
sleep 60

done
