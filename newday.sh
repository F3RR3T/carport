#!/usr/bin/bash
# Function to add a new directory if required

function newdaydir {
    thisdir=${1}
    yr=$(date +%Y)     # 4-digit year
    mo=$(date +%m)
    day=$(date +%d)
    today=${thisdir}/${yr}/${mo}/${day}
    if [ ! -d ${today} ]; then
	mkdir -p ${today}
    fi
    echo ${today}
}
