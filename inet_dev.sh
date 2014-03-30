#!/bin/bash

TIME_SAMPLE=10
MAX_SAMPLES=2

STATSD_HOST=localhost
STATSD_PORT=8125

STAT_PREFIX=mke.abortion
STATS_OUTPUT=""

IGNORE_DEVICES="(^veth.{6})"

tail -n+3 /proc/net/dev | sed 's/^\s\+//g' | egrep -v "^${IGNORE_DEVICES}" | \
( while read netstatLine; do \
    netdev=$(echo $netstatLine | cut -d' ' -f1 | sed 's/://g')
    ( \
        echo "${STAT_PREFIX}.inet_dev.${netdev}.rx.bytes:$(echo $netstatLine | cut -d' ' -f2)|c" ; \
		echo "${STAT_PREFIX}.inet_dev.${netdev}.rx.pkts:$(echo $netstatLine | cut -d' ' -f3)|c" ; \
		echo "${STAT_PREFIX}.inet_dev.${netdev}.tx.bytes:$(echo $netstatLine | cut -d' ' -f10)|c" ; \
		echo "${STAT_PREFIX}.inet_dev.${netdev}.tx.pkts:$(echo $netstatLine | cut -d' ' -f11)|c" ; \
    ) \
done ) | nc -w 1 -u $STATSD_HOST $STATSD_PORT

