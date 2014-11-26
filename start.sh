#!/bin/sh

CFG=/etc/haproxy/haproxy.cfg

/usr/bin/gen-haproxy-config -o $CFG $SERVICES

cat $CFG

exec haproxy -f $CFG -db

