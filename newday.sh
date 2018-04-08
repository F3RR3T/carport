#!/usr/bin/bash
# Function to add a new directory if required

function newdaydir {
	yr=$(date +%Y)     # 4-digit year
	mo=$(date +%m)
	day=$(date +%d)
	if [ ! -d ${yr}/${mo}/${day} ]; then
		mkdir -p ${yr}/${mo}/${day}
	fi
	echo ${yr}/${mo}/${day}
}
