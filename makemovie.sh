#!/usr/bin/bash
# Function to make a timelapse movie after sunset

function makemovie {
    framerate=${1:-24}  # default 24 frames per second
    mkdir -p mov        # temp directory
    find -name "*.jpg" | sort | gawk 'BEGIN{a=1}{printf "cp %s mov/%04d.jpg\n", $0, a++}' | bash
    movie=$(\date +%Y-%m-%d)_${cam}.mp4
    ffmpeg -r ${framerate} -i mov/%04d.jpg ${movie}
    rm mov/*.jpg
    rmdir mov
    mv ${movie} ${picdir}/mov/.
}
