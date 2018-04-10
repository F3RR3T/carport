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
    echo "MakeMovie started at $(\date)"
    mkdir -p mov        # temp directory
    find -name "*.jpg" | sort | gawk 'BEGIN{a=1}{printf "cp %s mov/%04d.jpg\n", $0, a++}' | bash
    movie=$(\date +%Y-%m-%d)_${cam}.mp4
    ffmpeg -hide_banner -nostats -v error -y -r ${framerate} -i mov/%04d.jpg ${movie}
    rm mov/*.jpg
    rmdir mov
    mv ${movie} ${picdir}/staging/.
    echo "MakeMovie finished at $(\date)"
}


cd ${picdir} 
# when a cam (takeminicampix.sh) senses sunset it writes a 'mark' file here
# The name of the markfile is in the format: "sunset-<camname>.mark"
# The file contains the path to the day's images.
for markfile in *.mark
do
    if [ ${#markfile[@]} -eq 0 ]; then 
        echo "No markfiles to process; stopping"
        exit 0
    fi
    if [[ ${markfile} == '*.mark' ]] ; then
        echo "Error: no markfiles therefore exiting."
        exit 1
    fi
    cam=${markfile#sunset-}     #strip prefix
    cam=${cam%.mark}            #strip extension
    echo markfile=${markfile}  cam=${cam}
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
    echo "Uploading ${movie} to ${web} started at $(\date)."
    scp staging/${movie} ${web}/mov/.
    rm staging/${movie}
    echo "Uploading finished at $(\date)."
done
