#!/bin/bash

test -e "/tmp/drain_${1}_${2}" && { echo -n 0 ; exit 0; } ;

#buf=$(ping -c 2 $1 &>/dev/null && timeout 20 curl --connect-timeout 10 -x socks4a://$1:$2 https://whatismyip.akamai.com )
buf=$(timeout 10 curl --connect-timeout 10 "http://$1:$2/lbcheck" )
echo "$buf" |grep -q ^Hello_from_fetch && echo -n 1
echo "$buf" |grep -q ^Hello_from_fetch || echo -n 0
