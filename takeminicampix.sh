#!/bin/bash
# takepix.sh  SJP 10 January 2017
cd /usr/local/bin/
# define newdaydir function and makemovie function
source newday.sh   

threshold=550 # Used to find photoes that are too dark (using imagemagick identify function)
    # threshold was found by trial and error for this particular camera/scene.
    # Is there a better way?
picdir="/path/to/my/photos"  # overwritten by sourcing from .picdir.config
declare -a camz
camz=(host1 host2 host3 etc) # overwritten by picdir.config
if [ -e picdir.config ]; then
    source picdir.config             # source directory name from local config file
else echo "picdir.config does not exist"; exit 1
fi

if [[ ${camz[0]} == 'host1' ]] ; then
    echo 'Error: camera host(s) not configured in picdir.config'
    exit 1
fi

timestamp=$(date +%Y-%m-%d_%H%M%S)

for cam in "${camz[@]}"
do
    # echo cam = $cam
    #artist=${cam}

    thiscam=${picdir}/${cam}
    todaydir=$(newdaydir ${thiscam})
    cd ${todaydir}
    #echo ${picdir}
    #echo ${cam}
    #echo ${todaydir}
    #echo "curl and store image to $PWD"
    curl -sO ${cam}/image.jpg
    #echo 'curl returned ' $?
    
    # weed out nightshots
    mean=$(identify -format %[mean] image.jpg | sed s/[.].*//)
    # echo Mean is ${mean}
    if [[ ${mean} < ${threshold} ]] ; then
        # echo 'Deleting night shot (mean='${mean}')'
        rm image.jpg
        # make a timelapse movie if this is the first darkshot
        if [ ! -e darkmarker ]; then 
            makemovie ${cam} $(date +%Y-%m-%d)
        fi
        touch darkmarker
        continue
    fi
    
    if [[ ${cam} == "carport" ]] ; then
        convert image.jpg -rotate 180 image.jpg
    fi
    mv image.jpg ${timestamp}.jpg
done
