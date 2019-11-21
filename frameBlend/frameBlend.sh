#!/bin/bash

# Copied from https://gist.github.com/antarktikali/d4ebdc5ebdc32f449827

mkdir new_frames
cp IMG_2985.JPG new_frames/previous.jpg
cd new_frames
counter=0

for f in ../IMG_*.JPG
  do
    for i in {0..20}
      do
        let "counter+=1"
        composite -blend $((i*5)) $f previous.jpg -matte blend_$counter.jpg
      done
    cp $f previous.jpg
  done

rm previous.jpg

ffmpeg -r "60" -i blend_%d.jpg -qscale 6 video.mp4
