#!/bin/bash
# takepix.sh  SJP 10 January 2017
cd /usr/local/bin/

picdir="/path/to/my/photos"  # overwritten by sourcing from .picdir.config
if [ -e picdir.config ]; then
    . picdir.config             # source directory name from local config file
else echo "picdir.config does not exist"; exit 1
fi
#echo camherder = $camherder
picdate=$(date +%Y-%m-%d_%H%M%S)
artist=carport

cd ${picdir}
curl -sO 133.7.0.103/image.jpg
mv image.jpg $picdate.jpg
