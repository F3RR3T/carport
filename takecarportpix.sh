#!/bin/bash
# takepix.sh  SJP 10 January 2017
cd /usr/local/bin/
. newday.sh

picdir="/path/to/my/photos"  # overwritten by sourcing from .picdir.config
if [ -e picdir.config ]; then
    . picdir.config             # source directory name from local config file
else echo "picdir.config does not exist"; exit 1
fi

#echo camherder = $camherder
picdate=$(date +%Y-%m-%d_%H%M%S)
artist=carport

cd ${picdir}
newdaydir
#echo 'getting image'
curl -sO 133.7.0.103/image.jpg
#echo 'curl returned $?'
mv image.jpg $picdate.jpg

# now weed out nightshots
mean=$(identify -format %[mean] ${picdate}.jpg | sed s/[.].*//)
if [[ ${mean} -lt 300 ]]; then
    #echo "Deleting night shot (mean=${mean})"
    rm ${picdate}.jpg
fi

# now make a movie
#mkdir mov
#find -name "*.jpg" | sort | gawk 'BEGIN{a=1}{printf "cp %s mov/%04d.jpg\n", $0, a++}' | bash
#ffmpeg -r 25  -i mov/%04d.jpg -qscale 8 farmfilm.mp4
