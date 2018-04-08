#!/bin/bash
# takepix.sh  SJP 10 January 2017
cd /usr/local/bin/
. newday.sh

threshold=550 # Used to find photoes that are too dark (using imagemagick identify function)
    # threshold was found by trial and error for this particular camera/scene.
    # Is there a better way?
picdir="/path/to/my/photos"  # overwritten by sourcing from .picdir.config
camz="host1 host2 host3 etc" # overwritten by picdir.config
if [ -e picdir.config ]; then
    . picdir.config             # source directory name from local config file
else echo "picdir.config does not exist"; exit 1
fi

if [ ${camz[1]} -eq 'host1' ] ; then
    echo "Error: camera host(s) not configured in picdir.config'
    exit 1
fi

for cam in "${camz[@]}"
do
    #echo camherder = $camherder
    picdate=$(date +%Y-%m-%d_%H%M%S)
    artist=${cam}

    cd ${picdir}
    newdaydir
    # echo 'curl and store image to '${picdir}
    curl -sO ${cam}/image.jpg
    # echo 'curl returned ' $?
    
    # weed out nightshots
    mean=$(identify -format %[mean] image.jpg | sed s/[.].*//)
    # echo "Mean is ${mean}"
    if [ ${mean} -lt ${threshold} ] ; then
        #  echo "Deleting night shot (mean=${mean})"
        rm image.jpg
        continue
    #else
        # echo "daytime!"
    fi
    
    if [ ${cam} -eq "carport" ] ; then
        convert image.jpg -rotate 180 image.jpg
    fi
    mv image.jpg ${cam}/${picdate}.jpg
done

