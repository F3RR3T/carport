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

function makemovie {
    mkdir -p mov
    find -name "*.jpg" | sort | gawk 'BEGIN{a=1}{printf "cp %s mov/%04d.jpg\n", $0, a++}' | bash
    ffmpeg -r 24 -i mov/%04d.jpg ${cam}$(date +%Y-%m-%d).mp4
    touch /home/st33v/cams/${cam}moviemark
}
