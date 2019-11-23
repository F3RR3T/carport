#!/bin/bash
# curlIsobar.sh
# SJP 23 November 2019
# 
# Copy weather charts from BOM.

rootURL='www.bom.gov.au/fwo'
rootChartName='IDY00030.'
dateUTC=$(date -u +%Y%m%d)
h=$(date -u +%H) 
h=${h#0}        # strip shortest match of '0', i.e. leading zero
echo "hour"  $h
h=$(($h / 6))
echo "modulo 6" $h
h=$(($h * 6))
echo "mult by 6" $h
h=$(printf "%02d" $h)
echo "printf" $h
hourExt="$h"00.png
echo "hourExt" $hourExt
chartURL=$rootURL/$rootChartName$dateUTC$hourExt
echo $chartURL

curl $chartURL -o chart.png

