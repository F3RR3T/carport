#!/usr/bin/bash
# Function to add a new directory if required

function newdaydir {
	yr=$(date +%Y)     # 4-digit year
	mo=$(date +%m)
	day=$(date +%d)
	if [ ! -d ${yr}/${mo}/${day} ]; then
		if [ ! -d ${yr}/${mo} ]; then
			if [ ! -d ${yr} ]; then
				mkdir ${yr}	
			fi
			mkdir ${yr}/${mo}
		fi
		mkdir ${yr}/${mo}/${day}
	fi
	cd ${yr}/${mo}/${day}
	echo $PWD
}
