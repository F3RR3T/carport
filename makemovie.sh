#!/usr/bin/bash
# called by uploadmovie.service, triggered by a change to picdir
picdir="/path/to/my/photos"  # overwritten by sourcing from paths.config
web="website.com/path/for/upload" # overwritten
if [ -e /usr/local/share/paths.config ]; then
    source /usr/local/share/paths.config             # source directory name from local config file
else echo "picdir.config does not exist"; exit 1
fi

picdir=${thisdir}/mov   # kludge until i rename var in paths.config

# Function to make a timelapse movie after sunset
function MakeMovie {
    framerate=${1:-24}  # default 24 frames per second
    begin=$(date +"%s")
    # echo "MakeMovie started"
    mkdir -p mov        # temp directory
    find -name "*.jpg" | sort | gawk 'BEGIN{a=1}{printf "cp %s mov/%04d.jpg\n", $0, a++}' | bash
    movie=$(\date +%Y-%m-%d)_${cam}.mp4
    ffmpeg -hide_banner -nostats -v error -y -r ${framerate} -i mov/%04d.jpg ${movie}
    rm mov/*.jpg
    rmdir mov
    mv ${movie} ${picdir}/staging/.
    finish=$(date +"%s")
    echo "MakeMovie took $((${finish} - ${begin})) sec."
}


cd ${picdir} 
# when a cam (takeminicampix.sh) senses sunset it writes a 'mark' file here
# The name of the markfile is in the format: "sunset-<camname>.mark"
# The file contains the path to the day's images.
for markfile in *.mark
do
    if [[ ${markfile} == '*.mark' ]] ; then
        echo "No markfiles therefore exiting."
        exit 0 
    fi
    cam=${markfile#sunset-}     #strip prefix
    cam=${cam%.mark}            #strip extension
    # echo markfile=${markfile}  cam=${cam}
    sourcedir=$(cat ${markfile})
    cd ${sourcedir}
    echo sourcedir ${sourcedir}
    if [[ $PWD == "/home/st33v" ]] ; then 
        echo "Error: bad sourcedir: ${sourcedir}"
        cd ${picdir}   # reset for next iteration
        rm ${markfile}
        continue 
    fi
    MakeMovie
    cd ${picdir}
    rm ${markfile}

    # upload
    begin=$(date +"%s")
    scp staging/${movie} ${web}/mov/.
    rm staging/${movie}
    finish=$(date +"%s")
    echo "Upload of ${movie} to ${web} took $((${finish} - ${begin})) sec."
done
