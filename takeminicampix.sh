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
if [ -e /usr/local/share/picdir.config ]; then
    source /usr/local/share/picdir.config             # source directory name from local config file
else echo "picdir.config does not exist"; exit 1
fi

if [[ ${camz[0]} == 'host1' ]] ; then
    echo 'Error: camera host(s) not configured in picdir.config'
    exit 1
fi

timestamp=$(date +%Y-%m-%d_%H%M%S)

for cam in "${camz[@]}"
do
    #artist=${cam}

    thiscam=${picdir}/${cam}
    todaydir=$(newdaydir ${thiscam})
    cd ${todaydir}
    #echo ${picdir}
    #echo ${todaydir}
    #echo "curl and store image to $PWD"
    curl -sO ${cam}/image.jpg
    curlexit=$?
    #echo 'curl for '${cam}' returned ' $? $curlexit
    
    # weed out nightshots
    if [ "$curlexit" == '7' ] ; then 
        #echo 'Error: no image from' ${cam} '('${curlexit}')'
        continue   # loop if curl exited badly
    fi
    mean=$(identify -format %[mean] image.jpg | sed s/[.].*//)
     #echo Mean is ${mean}
    if [ ${mean} -lt ${threshold} ] ; then
        # echo 'Deleting night shot (mean='${mean}')'
        rm image.jpg
        # Has the sun gone down (after noon, not after midnight)
        thishour=$(date +%H)    # hour as a number 00-24
        if [[ ${thishour} > 12 ]] ; then
            if [ ! -e sunset ]; then 
               # create a file in the directory that is monitored by Systemd uploadmovie.path unit
               echo ${todaydir} > ${picdir}/mov/sunset-${cam}.mark
               echo 'Sunset has occured for ${cam} camera'
               touch sunset   # prevent further 'Sunset' registrations today for this cam 
            fi
        fi
        continue
    fi
    
    if [[ ${cam} == "carport" ]] ; then
        convert image.jpg -rotate 180 image.jpg
    fi
    mv image.jpg ${timestamp}.jpg
done
