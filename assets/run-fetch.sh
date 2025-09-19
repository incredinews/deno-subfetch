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
   cp /usr/bin/subfetch /usr/bin/subfetch.prev
   mkdir /tmp/cache
   mv     /root/.cache/deno   /tmp/cache/deno 
   ln -s  /tmp/cache/deno     /root/.cache/deno
   mkdir /tmp/deno
   export DENO_DIR=/tmp/deno
   cd /app ; deno cache --allow-import index.ts && deno compile --allow-all --no-check --v8-flags="--expose-gc" --output /usr/bin/subfetch index.ts 2>&1|grep -v "Download"
   du -m -s /root/.deno /root/.cache/deno /app /tmp/deno
   rm -rf /root/.deno /root/.cache/deno /tmp/cache/deno /tmp/deno
   test -e /usr/bin/subfetch || echo "/usr/bin/subfetch missing after compile"
   test -e /usr/bin/subfetch || cp /usr/bin/subfetch.prev /usr/bin/subfetch
   echo "done compiling"
}

test -e /etc/connector.conf &&  ( echo "start conn..."; while (true);do sleep 2;/connector --config /etc/connector.conf  2>&1 |grep -v -e decryp -e key -e keepalive -e ndshake -e TUN -e Interface -e encryp ;done) &

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
