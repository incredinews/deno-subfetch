#!/bin/bash


test -e /setup.sh && source /setup.sh
function outlog() {
   cat
}
[[ "${OTEL_DENO}" == "true" ]] && function outlog() {
   /bin/bash /etc/otl_snd.sh
}
[[ "${OTEL_DENO}" == "true" ]] && {
    echo "RECOMPILING..."

   cd /app ; deno cache --allow-import index.ts && deno compile --allow-all --no-check --v8-flags="--expose-gc" --output /usr/bin/subfetch index.ts 2>&1|grep -v "Download"
   rm -rf /root/.deno /app
}
test -e /etc/connector.conf &&  ( echo "start conn..."; /connector --config /etc/connector.conf  2>&1 |grep -v -e decryp -e key -e keepalive -e ndshake -e TUN -e Interface -e encryp ) &
( /usr/bin/gobetween -c /etc/gobtw.toml 2>&1 | grep -v "ending to scheduler" ) &

#date +%s > /tmp/drain_127.0.0.1_10002
echo 10001 > /tmp/myport.fetch
while (true); do 
#myport=10001

#for m in 1 2 3 4 5;do 
#test -e /tmp/drain_127.0.0.1_$myport && myport=$(($myport+1))
#done
myport=$(cat /tmp/myport.fetch)
## test -e /tmp/drain_127.0.0.1_$myport || myport=10002
[[ "$DEBUG"  == "true" ]] && echo "SWITCH_PORT: $myport"
export PORT=$myport
test -e /tmp/drain_127.0.0.1_$myport  && rm /tmp/drain_127.0.0.1_$myport ;
timeout 420 /usr/bin/subfetch | outlog &
sleep 333 ; 
( sleep 10 ; touch  /tmp/drain_127.0.0.1_$myport ) &

[[ "$myport" == "10001" ]] && (echo 10002 > /tmp/myport.fetch  )
[[ "$myport" == "10002" ]] && (echo 10001 > /tmp/myport.fetch  )
done
