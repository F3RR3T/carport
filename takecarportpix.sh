#!/bin/bash
# takepix.sh  SJP 10 January 2017
cd /usr/local/bin/
. newday.sh

threshold=550 # Used to find photoes that are too dark (using imagemagick identify function)
    # threshold was found by trial and error for this particular camera/scene.
    # Is there a better way?
picdir="/path/to/my/photos"  # overwritten by sourcing from .picdir.config
if [ -e picdir.config ]; then
    . picdir.config             # source directory name from local config file
else echo "picdir.config does not exist"; exit 1
fi

#echo camherder = $camherder
picdate=$(date +%Y-%m-%d_%H%M%S)
artist=carport

cd ${picdir}
today=$(newdaydir)
# echo 'curl and store image to '${picdir}
curl -sO carport/image.jpg
# echo 'curl returned ' $?
mv image.jpg ${today}/$picdate.jpg

# now weed out nightshots
mean=$(identify -format %[mean] ${picdate}.jpg | sed s/[.].*//)
# echo "Mean is ${mean}"
if [ ${mean} -lt ${threshold} ] ; then
    #  echo "Deleting night shot (mean=${mean})"
    rm ${picdate}.jpg
#else
    # echo "daytime!"
fi

# now make a movie
#mkdir mov
#find -name "*.jpg" | sort | gawk 'BEGIN{a=1}{printf "cp %s mov/%04d.jpg\n", $0, a++}' | bash
#ffmpeg -r 25  -i mov/%04d.jpg -qscale 8 farmfilm.mp4
