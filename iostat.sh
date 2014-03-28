#!/bin/bash

TIME_SAMPLE=10
MAX_SAMPLES=2

STATSD_HOST=localhost
STATSD_PORT=8125

STAT_PREFIX=mke.abortion

MAX_DEVICES=20

if ! which iostat >&/dev/null; then
	echo "Cannot find iostat in \$PATH" >&2
	exit 1
fi

if ! which tac >&/dev/null; then
	echo "Cannot find tac in \$PATH" >&2
	exit 1
fi

iostat -x $TIME_SAMPLE $MAX_SAMPLES | tac | egrep -B${MAX_DEVICES} -m1 ^Device | egrep -v -e ^Device -e '^\s*$' | \
( while read iostatLine; do \
    iodev=$(echo $iostatLine | cut -d' ' -f1)
    ( \
        echo "${STAT_PREFIX}.iostat.${iodev}.rrqms:$(echo $iostatLine | cut -d' ' -f2)|g" ; \
        echo "${STAT_PREFIX}.iostat.${iodev}.wrqms:$(echo $iostatLine | cut -d' ' -f3)|g" ; \
        echo "${STAT_PREFIX}.iostat.${iodev}.rs:$(echo $iostatLine | cut -d' ' -f4)|g" ; \
        echo "${STAT_PREFIX}.iostat.${iodev}.ws:$(echo $iostatLine | cut -d' ' -f5)|g" ; \
        echo "${STAT_PREFIX}.iostat.${iodev}.rKBs:$(echo $iostatLine | cut -d' ' -f6)|g" ; \
        echo "${STAT_PREFIX}.iostat.${iodev}.wKBs:$(echo $iostatLine | cut -d' ' -f7)|g" ; \
        echo "${STAT_PREFIX}.iostat.${iodev}.avgrq-sz:$(echo $iostatLine | cut -d' ' -f8)|g" ; \
        echo "${STAT_PREFIX}.iostat.${iodev}.avgqu-sz:$(echo $iostatLine | cut -d' ' -f9)|g" ; \
        echo "${STAT_PREFIX}.iostat.${iodev}.await:$(echo $iostatLine | cut -d' ' -f10)|g" ; \
        echo "${STAT_PREFIX}.iostat.${iodev}.r_await:$(echo $iostatLine | cut -d' ' -f11)|g" ; \
        echo "${STAT_PREFIX}.iostat.${iodev}.w_await:$(echo $iostatLine | cut -d' ' -f12)|g" ; \
        echo "${STAT_PREFIX}.iostat.${iodev}.svctm:$(echo $iostatLine | cut -d' ' -f13)|g" ; \
        echo "${STAT_PREFIX}.iostat.${iodev}.percentutil:$(echo $iostatLine | cut -d' ' -f14)|g" \
    ) \
done ) |  nc -w 1 -u $STATSD_HOST $STATSD_PORT

