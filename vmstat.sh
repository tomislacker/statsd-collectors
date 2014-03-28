#!/bin/bash

TIME_SAMPLE=3
MAX_SAMPLES=2

STATSD_HOST=localhost
STATSD_PORT=8125

STAT_PREFIX=mke.abortion

if ! which vmstat >&/dev/null; then
	echo "Cannot find vmstat in \$PATH" >&2
	exit 1
fi

( vmStatOut=$(vmstat -na $TIME_SAMPLE $MAX_SAMPLES | tail -n1) ; \
	proc_r=$(echo $vmStatOut | cut -d' ' -f1) ; \
	proc_b=$(echo $vmStatOut | cut -d' ' -f2) ; \
	mem_swpd=$(echo $vmStatOut | cut -d' ' -f3) ; \
	mem_free=$(echo $vmStatOut | cut -d' ' -f4) ; \
	mem_inac=$(echo $vmStatOut | cut -d' ' -f5) ; \
	mem_acti=$(echo $vmStatOut | cut -d' ' -f6) ; \
	swap_si=$(echo $vmStatOut | cut -d' ' -f7) ; \
	swap_so=$(echo $vmStatOut | cut -d' ' -f8) ; \
	io_bi=$(echo $vmStatOut | cut -d' ' -f9) ; \
	io_bo=$(echo $vmStatOut | cut -d' ' -f10) ; \
	sys_in=$(echo $vmStatOut | cut -d' ' -f11) ; \
	sys_cs=$(echo $vmStatOut | cut -d' ' -f12) ; \
	cpu_us=$(echo $vmStatOut | cut -d' ' -f13) ; \
	cpu_sys=$(echo $vmStatOut | cut -d' ' -f14) ; \
	cpu_id=$(echo $vmStatOut | cut -d' ' -f15) ; \
	cpu_wa=$(echo $vmStatOut | cut -d' ' -f16) ; \
	( \
	    echo "${STAT_PREFIX}.vmstat.proc_r:${proc_r}|g" ;
	    echo "${STAT_PREFIX}.vmstat.proc_b:${proc_b}|g" ;
	    echo "${STAT_PREFIX}.vmstat.mem_swpd:${mem_swpd}|g" ;
	    echo "${STAT_PREFIX}.vmstat.mem_free:${mem_free}|g" ;
	    echo "${STAT_PREFIX}.vmstat.mem_inac:${mem_inac}|g" ;
	    echo "${STAT_PREFIX}.vmstat.mem_acti:${mem_acti}|g" ;
	    echo "${STAT_PREFIX}.vmstat.swap_si:${swap_si}|c" ;
	    echo "${STAT_PREFIX}.vmstat.swap_so:${swap_so}|c" ;
	    echo "${STAT_PREFIX}.vmstat.io_bi:${io_bi}|c" ;
	    echo "${STAT_PREFIX}.vmstat.io_bo:${io_bo}|c" ;
	    echo "${STAT_PREFIX}.vmstat.sys_in:${sys_in}|g" ;
	    echo "${STAT_PREFIX}.vmstat.sys_cs:${sys_cs}|g" ;
	    echo "${STAT_PREFIX}.vmstat.cpu_us:${cpu_us}|g" ;
	    echo "${STAT_PREFIX}.vmstat.cpu_sys:${cpu_sys}|g" ;
	    echo "${STAT_PREFIX}.vmstat.cpu_id:${cpu_id}|g" ;
	    echo "${STAT_PREFIX}.vmstat.cpu_wa:${cpu_wa}|g" \
    ) | nc -w 1 -u $STATSD_HOST $STATSD_PORT ; \
) &
	
