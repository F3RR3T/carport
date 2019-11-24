#!/bin/bash
# curlIsobar.sh
# SJP 23 November 2019
# 
# Copy weather charts from BOM.

function curlIsobar() {
    chartDir='/home/st33v/dev/carport/frameBlend'
    cd $chartDir
    rootURL='www.bom.gov.au/fwo/IDY00030'
    dateUTC=$(date -u +%Y%m%d)
    h=$(date -u +%H) 
    h=${h#0}        # strip shortest match of '0', i.e. leading zero
    h=$(($h / 6))   # '0' to '3' (integer division)
    h=$(($h * 6))   # Now mult by 6 to get 0, 6, 12, 18
    h=$(printf "%02d" $h)   # repad with leading zero if required.
    hourExt="$h"00.png
    fileName=$dateUTC$hourExt   # Specifies remote file and locale file
    chartURL=$rootURL.$fileName  # ready to cURL

    # Fetch the lastest isobaric chart (or get a 404 HMTL page)
    # We could fancify this by just retrieving the HTTP response code like this:
    #  http=$(curl <url> -io /dev/null -w "%{http_code}")
    curl $chartURL -o newCharts/$fileName

    # Did we actually get a PNG file?
    filetype=$(file -b newCharts/$fileName | awk '{print $1}')
    echo $filetype

    if [ $filetype ==  'HTML' ] ; then
        systemd-run --unit=retryCurlIsobar --uid=1000 --gid=1000 --on-active=900 ./curlIsobar.sh
        echo "retrying"
    else
        if [ $filetype =='PNG' ] ; then
            echo $fileName > latest
        else 
            echo "cURL returned a bad file"
            exit(1)
        fi
    fi
}
